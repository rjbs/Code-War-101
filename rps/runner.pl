#!/usr/bin/env perl
use 5.12.0;
use warnings;

use IPC::Open2 qw(open2);

my %valid  = map {; $_ => 1 } qw(rock paper scissors);
my %winner = (
  rockscissors  => 1,
  rockpaper     => 2,
  paperrock     => 1,
  paperscissors => 2,
  scissorspaper => 1,
  scissorsrock  => 2,
);

my $cmd1  = $ARGV[0] // die "not enough args";
my $cmd2  = $ARGV[1] // die "not enough args";
my $times = $ARGV[2] // die "not enough args";

my ($r1, $w1, $r2, $w2);
my $pid1 = open2 $r1, $w1, $cmd1;
my $pid2 = open2 $r2, $w2, $cmd2;

print {$w1} "init\n";
print {$w2} "init\n";

my %score = (
  0 => 0,
  1 => 0,
  2 => 0,
);

for (1 .. $times) {
  my $play1 = <$r1>;
  my $play2 = <$r2>;

  chomp($play1, $play2);

  my @result = result($play1, $play2);
  $SIG{PIPE} = 'IGNORE'; # <-- lame
  s/ /-/g for $play1, $play2;
  print { $w1 } "$play1 $play2 $result[0]\n"; # you them result
  print { $w2 } "$play2 $play1 $result[1]\n";

  $score{0}++ if $result[0] eq 'tie';
  $score{1}++ if $result[0] eq 'win';
  $score{2}++ if $result[1] eq 'win';

  say "Player 1: $score{1}";
  say "Player 2: $score{2}";
  say "Ties    : $score{0}";
}

close $_ for ($r1, $w1, $r2, $w2);

sub result {
  my ($p1, $p2) = @_;
  warn "<$p1> <$p2>\n";
  return qw(dq   dq)   if !$valid{$p1} && !$valid{$p2};
  return qw(dq   win)  if !$valid{$p1};
  return qw(win  dq)   if !$valid{$p2};
  return qw(tie  tie)  if $p1 eq $p2;

  my $winner = $winner{"$p1$p2"};
  return qw(win  lose) if $winner == 1;
  return qw(lose win)  if $winner == 2;

  die "something very strange has happened: <<$p1> <$p2>>";
}

