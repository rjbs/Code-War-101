#!/usr/bin/perl
use strict;
use warnings;
$|++;

my $init;
my $lastmove;
while (! $init) {
    $init++ if <STDIN> =~ /^init$/;
}

my $move = firstmove();
$lastmove = $move;
print "$move\n";

while (my $input = <STDIN>) {
    chomp ($input);
    my ($us, $them, $result) = split /\s+/, $input;
    last if ( ! defined $us or ! $us eq $lastmove );
    last if ( ! defined $result or $result !~ /win|lose|dq|tie/ );

    my $move = ( $them eq "rock" ) ? "paper" :
               ( $them eq "paper" ) ? "scissors" :
               ( $them eq "scissors" ) ? "rock" : firstmove();

    last $init unless ( $move );

    $lastmove = $move;
    print "$move\n"

}

sub firstmove {
    my @range=(0 .. 2);
    my %play = ( 0 => 'rock', 1 => 'paper', 2 => 'scissors' );
    return $play{$range[rand(@range)]};
}
