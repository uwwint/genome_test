#!/usr/bin/env perl

# This script was written by Brian Hass as part of the Trinity
# transcriptome package. All credit to him!
# https://github.com/trinityrnaseq/trinityrnaseq

use strict;
use warnings;

while (<>) {
    if (/>(\S+)/) {
        my $acc = $1;
        if ($acc =~ /^(.*c\d+_g\d+)(_i\d+)/) {
            my $gene = $1;
            my $trans = $1 . $2;

            print "$gene\t$trans\n";
        }
        elsif ($acc =~ /^(.*comp\d+_c\d+)/) {
            my $gene = $1;
            my $trans = $acc;
            print "$gene\t$trans\n";
        }
        else {
            print STDERR "WARNING: cannot decipher accession $acc\n";
        }
    }
}

exit(0);