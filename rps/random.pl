#!/usr/bin/env perl
use 5.18.1;
$|++;

my @options = qw(rock paper scissors);

while (my $status = <STDIN>) {
  # warn "rand STATUS: $status";
  say $options[ int rand @options ];
}
