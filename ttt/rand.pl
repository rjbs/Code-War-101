#!/usr/bin/perl
use 5.12.0;
$|++;
while (my $line = <STDIN>) {
  $line =~ s/\R\z//;
  my ($me, $board) = $line =~ /\A(.) ([ 0-9]{9})$/;
  my @indices = grep { ' ' eq substr $board, $_, 1 } (0 .. 8);

  my $pick = $indices[ int rand @indices ];
  print "$pick\n";
}
