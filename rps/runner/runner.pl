#!/usr/bin/env perl
use 5.10.1;
use warnings;

use Cwd 'getcwd';
use Getopt::Long::Descriptive;
use IPC::Open2 qw(open2);

my ($opt, $desc) = describe_options(
  "%c %o <program> ...",
  [ "rounds|r=i", "rounds to run each pairing", { default => 10 } ],
  [ "focus",      "focus on results with first bot"               ],
);

my %valid  = map {; $_ => 1 } qw(rock paper scissors);
my %winner = (
  rockscissors  => 1,
  rockpaper     => 2,
  paperrock     => 1,
  paperscissors => 2,
  scissorspaper => 1,
  scissorsrock  => 2,
);

die "not enough args" unless @ARGV > 1;

my %final_wins;
my %pairing;
my @bots = @ARGV;

for my $i ($opt->focus ? 0 : (0 .. $#bots)) {
  for my $j (0 .. $#bots) {
    my $score = run_one_pair($i, $j);
    my ($w1, $w2) =
    $final_wins{ $i } += $score->{1};
    $final_wins{ $j } += $score->{2};
    $pairing{$i}{$j} = $score;
  }
}

printf " %16s  |  %16s  | %6s | %6s | %6s | %6s\n",
  'Player 1', 'Player 2', qw(win lose tie ddq);
print  "-" x 75, "\n";
for my $i (sort { $a <=> $b } keys %pairing) {
  for my $j (sort { $a <=> $b } keys %{ $pairing{$i} }) {
    my $score = $pairing{$i}{$j};
    printf "(%16s) v (%16s) : %6d - %6d - %6d - %6d\n",
      $bots[$i], $bots[$j], @$score{qw(1 2 tie ddq)};
  }
}

for (sort { $final_wins{$b} <=> $final_wins{$a} } 0 .. $#bots) {
  printf "%2u. %20s: %6s\n", $_, $bots[$_], $final_wins{ $_ };
}

sub run_one_pair {
  my ($i, $j) = @_;
  my $cmd1 = $bots[$i];
  my $cmd2 = $bots[$j];

  my ($r1, $w1, $r2, $w2);
  local $ENV{PATH} = getcwd . ":$ENV{PATH}"; # <-- ridiculous
  my $pid1 = open2 $r1, $w1, $cmd1;
  my $pid2 = open2 $r2, $w2, $cmd2;

  print {$w1} "init\n";
  print {$w2} "init\n";

  my %score = (
    ddq => 0,
    tie => 0,
    1   => 0,
    2   => 0,
  );

  for (1 .. $opt->rounds) {
    my $play1 = eof $r1 ? 'DEAD' : <$r1>;
    my $play2 = eof $r2 ? 'DEAD' : <$r2>;

    chomp($play1, $play2);

    my @result = result($play1, $play2);
    $SIG{PIPE} = 'IGNORE'; # <-- lame
    s/[^a-z0-9]/-/ig for $play1, $play2;
    length $_ or $_ = '-' for $play1, $play2;
    print { $w1 } "$play1 $play2 $result[1]\n"; # you them result
    print { $w2 } "$play2 $play1 $result[2]\n";

    $score{ $result[0] }++;

    printf "%-16s: $score{1}\n", $bots[$i];
    printf "%-16s: $score{2}\n", $bots[$j];
    say "Ties    : $score{tie}";
    say "DDQ     : $score{ddq}";
  }

  close $_ for ($r1, $w1, $r2, $w2);

  return \%score;
}

sub result {
  my ($p1, $p2) = @_;
  warn "<$p1> <$p2>\n";
  return qw(ddq dq   dq)   if !$valid{$p1} && !$valid{$p2};
  return qw(2   dq   win)  if !$valid{$p1};
  return qw(1   win  dq)   if !$valid{$p2};
  return qw(tie tie  tie)  if $p1 eq $p2;

  my $winner = $winner{"$p1$p2"};
  return qw(1   win  lose) if $winner == 1;
  return qw(2   lose win)  if $winner == 2;

  die "something very strange has happened: <<$p1> <$p2>>";
}

