#!/usr/bin/perl

use strict;
use warnings;

my $dir = "tmp";
my $n = 0;
my @links;
mkdir $dir || die $!;
eval {
    foreach my $file (sort @ARGV) {
        my $link = sprintf("$dir/%d.jpg", $n++);
        print "Link $file -> $link\n";
        link($file, $link) || die $!;;
        push @links, $link;
    }
sleep 1;
    system("../ffmpeg/ffmpeg","-r","30","-sameq","-i","$dir/%d.jpg","test.mp4");
};
warn $@ if $@;

foreach my $link (@links) {
    unlink $link || warn "Unlink $link: $!";
}
rmdir $dir || warn "Rmdir $dir: $!";

