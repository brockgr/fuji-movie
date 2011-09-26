#!/usr/bin/perl

use strict;
use warnings;
use Check;
use Astro::Sunrise;


system('rm -f test/good/* test/bad/*');

    foreach my $date (sort <201002??>) {
        my ($y,$m,$d) = unpack("A4 A2 A2", $date);
        my ($sunrise, $sunset) = Astro::Sunrise::sunrise($y,$m,$d, 138.731, 35.358, 9, 0, -10);
        s/:// foreach ($sunrise, $sunset);

        foreach my $file (sort <$date/${date}_????_Web.jpg>) {

            my ($time) = ($file =~ m/_(\d{4})_/);
            next if $time < $sunrise;
            next if $time > $sunset;

            print "$file\n";

            my $img = Imager->new(file => $file) or die Imager->errstr();
            (my $name = $file) =~ s/.*\///;
            if (check($img)) {
                link "$file", "test/good/$name" || die $!;
            } else {
                link "$file", "test/bad/$name" || die $!;
            }

        }
    }
