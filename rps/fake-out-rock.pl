#!/usr/bin/env perl
use 5.18.0;
$|++;

my @options = qw(rock paper scissors);

while (my $status = <STDIN>) {
  say $. <= 10 ? 'rock' : $options[ int rand @options ];
}
