#!/usr/bin/env perl
use 5.10.1;
$|++;

my %play = (
  rock     => 'paper',
  paper    => 'scissors',
  scissors => 'rock',
);

my %last;
while (my $status = <STDIN>) {
  chomp $status;
  @last{qw(we them result)} = $status eq 'init' ? () : (split / /, $status);
  if ($last{them}) {
    say $play{ $last{them} };
  } else {
    say((values %play)[ int rand +(values %play) ]);
  }
}
