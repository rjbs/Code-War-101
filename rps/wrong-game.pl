#!/usr/bin/env perl
use 5.10.1;
$|++;

my @full    = qw(rock paper scissors lizard spock);
my @limited = qw(rock paper scissors);

while (my $status = <STDIN>) {
  if ($status =~ /DEAD/) {
    say $limited[ int rand @limited ];
  } else {
    say $full[ int rand @full ];
  }
}
