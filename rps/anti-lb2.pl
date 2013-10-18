#!/usr/bin/env perl
use 5.18.0;
$|++;

my %play = (
  rock     => 'paper',
  paper    => 'scissors',
  scissors => 'rock',
);

my @options = qw(rock paper scissors);
my @we;
my @they;
my %count;

while (my $status = <STDIN> ) {
    chomp $status;
    if ($status eq 'init') {
#        say STDERR 'first time random';
        say $options[ int rand @options ];
    } else {
        my ($we, $they, $result) = split / /, $status;
        push @we, $we;
        push @they, $they;

        if (@they > 3) {
            my $key = join '', @they[-3..-2];
            $key .= $we;
            $count{$key}++;
        }

        if ($. <= 10) {
            # accumulate some data
#            say STDERR 'first 10 random';
            say $options[ int rand @options ];
        } else {
            my $last2 = join '', @they[-2..-1];
            my @cnt;
            $cnt[0] = $count{$last2 . 'rock'};
            $cnt[1] = $count{$last2 . 'paper'};
            $cnt[2] = $count{$last2 . 'scissors'};

            my $likely = $options[maxidx(@cnt)];
            my $debug = join ",", @cnt;
#            say STDERR $debug;
#            say STDERR "likely is $likely";
            say $play{$play{$likely}};
        }
    }
}

sub maxidx {
    my @a = @_;

    if ($#a == -1) {
        return -1;
    } else {
        my $max = 0;
        for my $i(1..$#a) {
            $max = $i if $a[$i] > $a[$max];
        }
        local $" = ", ";
#        say STDERR "in maxidx: @a $max";
        return $max;
    }
}


