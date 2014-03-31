#!/usr/bin/perl

# I spell things

use strict;
use warnings;

use List::Util qw(shuffle);

$|++;

my @plays = (
  [ qw(0 1 2 4 7)         ], # t
  [ qw(0 1 2 4 7 6 8)     ], # i 
  [ qw(2 1 0 3 6 7 8)     ], # c
  [ qw(0 1 2 4 7)         ], # t
  [ qw(6 3 0 1 2 5 8 4)   ], # a
  [ qw(2 1 0 3 6 7 8)     ], # c
  [ qw(0 1 2 4 7)         ], # t
  [ qw(0 1 2 5 8 7 6 3)   ], # o
  [ qw(3 4 5 2 1 0 6 7 8) ], # e
);

my $shuffled = 0;
my $cplay;

while (my $line = <STDIN>) {
  if ($line =~ /^printit$/) {
    show_plays();
    exit;
  } elsif (!$shuffled++) {
    @plays = shuffle(@plays);
    $cplay = $plays[0];
  }

  $line =~ s/\R\z//;
  my ($me, $board) = $line =~ /\A(.) ([ 0-9]{9})$/;

  # Easier tracking
  my %board = map { $_ => 0 } (0..8);
  my %used = map { $_ => 1 } grep { ' ' ne substr $board, $_, 1 } (0 .. 8);
  my @unused = grep { !$used{$_} } (0..8);

  # See if we can play through our letter
  my $next = shift @$cplay;
  while (defined $next && $used{$next}) {
    $next = shift @$cplay;
  }

  # Bah, our moves are used up. Just fill in the rest of the board
  if (!$next) {
    $next = shift @unused;
  }
  print $next . "\n";
}

sub show_plays {
  for my $p (@plays) {
    my %ids = map { $_ => 1 } @$p;

    for (1..9) {
      print $ids{$_-1} || ' ';
      if ( !($_ % 3) ) {
        print "\n";
      }
    }
    print "\n";
  }
}
