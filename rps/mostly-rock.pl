#!/usr/bin/env perl
use 5.18.0;
$|++;

my @options = qw(rock rock rock rock rock
                 paper paper paper
                 scissors scissors);

while (my $status = <STDIN>) {
  say $options[ int rand @options ];
}
