#!/usr/bin/env perl
use 5.14.0;
use warnings;

use Cwd 'getcwd';
use Getopt::Long::Descriptive;
use IPC::Open2 qw(open2);

my ($opt, $desc) = describe_options(
  "%c %o <program> ...",
  [ "rounds|r=i", "rounds to run each pairing", { default => 10 } ],
  [ "focus",      "focus on results with first bot"               ],
);

die "not enough args" unless @ARGV;

my %pairing;
my @bots = @ARGV;
my %final_wins;

my @runs = (
  [ 0, 1, 2 ],
  [ 3, 4, 5 ],
  [ 6, 7, 8 ],

  [ 0, 3, 6 ],
  [ 1, 4, 7 ],
  [ 2, 5, 8 ],

  [ 0, 4, 8 ],
  [ 6, 4, 2 ],
);

for my $i ($opt->focus ? 0 : (0 .. $#bots)) {
  for my $j (0 .. $#bots) {
    my $score = run_one_pair($i, $j);
    $final_wins{ $i } += $score->{0};
    $final_wins{ $j } += $score->{1};
    $pairing{$i}{$j} = $score;
  }
}

printf " %16s  |  %16s  | %6s | %6s | %6s | %6s\n",
  'Player 1', 'Player 2', qw(win lose tie ddq);
print  "-" x 75, "\n";
for my $i (sort { $a <=> $b } keys %pairing) {
  for my $j (sort { $a <=> $b } keys %{ $pairing{$i} }) {
    my $score = $pairing{$i}{$j};
    printf "(%x-%14s) v (%x-%14s) : %6d - %6d - %6d - %6d\n",
      $i, $bots[$i], $j, $bots[$j], @$score{qw(0 1 tie ddq)};
  }
}

for (sort { $final_wins{$b} <=> $final_wins{$a} } 0 .. $#bots) {
  printf "%2u. %20s: %6s\n", $_, $bots[$_], $final_wins{ $_ };
}

sub run_one_pair {
  my ($i, $j) = @_;

  my @p = ( {}, {} );

  $p[0]{cmd} = $bots[$i];
  $p[1]{cmd} = $bots[$j];

  local $ENV{PATH} = getcwd . ":$ENV{PATH}"; # <-- ridiculous
  local $SIG{PIPE} = 'IGNORE'; # <-- lame

  $p[$_]{pid} = open2 $p[$_]{r}, $p[$_]{w}, $p[$_]{cmd} for (0, 1);

  my %score = (
    ddq => 0,
    tie => 0,
    0   => 0,
    1   => 0,
  );

  my $next = 0;

  for (1 .. $opt->rounds) {
    my $board = [ (undef) x 9 ];

    my $result;
    until (defined $result) {
      print { $p[$next]{w} } $next, " ", board_string($board), "\n";
      my $move = readline $p[$next]{r};
      $move =~ s/\R\z//;
      $result = apply_move($board, $move, $next);
      $next = ($next + 1) % 2;
    }

    warn "FINAL: \n" . (board_diagram($board) =~ s/^/  /grm) . "\n";
    $score{ $result }++;

    warn sprintf "%-16s: $score{0}\n", $bots[$i];
    warn sprintf "%-16s: $score{1}\n", $bots[$j];
    warn sprintf "Ties    : $score{tie}\n";
    warn sprintf "DDQ     : $score{ddq}\n";
  }

  close $_ for map {; @$_{qw(r w)} } @p;

  kill 'TERM', $p[0]{pid};
  kill 'TERM', $p[1]{pid};

  waitpid $p[0]{pid}, 0;
  waitpid $p[1]{pid}, 0;

  return \%score;
}

sub apply_move {
  my ($board, $move, $marker) = @_;

  my $other = $marker+1 % 2;

  return $other unless $move =~ /\A[0-9]\z/;
  return $other unless $move >= 0 and $move <= 9;
  return $other if defined $board->[$move];

  $board->[ $move ] = $marker;

  # NOT REAL TIC TAC TOE! :) -- rjbs, 2014-03-28
  RUN: for my $run (@runs) {
    ($board->[$_] // ' ') eq $marker || next RUN for @$run;
    return $marker;
  }

  return 'tie' unless grep {; ! defined } @$board;

  return;
}

sub board_string {
  my ($board) = @_;
  join q{}, map { $_ // ' ' } @$board;
}

sub board_diagram {
  my ($board) = @_;
  my $str;
  for my $r (0 .. 2) {
    $str .= join(q{ }, map {; $board->[ $r * 3 + $_ ] // '-' } (0 .. 2))
         .  "\n";
  }

  $str =~ tr/01/XO/;

  return $str;
}

