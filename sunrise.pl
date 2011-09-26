#!/usr/bin/perl

# Animate all sunrise images

use strict;
use warnings;
use Check;
use Astro::Sunrise;

my $dir  = "tmp";
my $rate = 15;
my $curve = 0;# 2;

my $font = Imager::Font->new(file => '/Library/Fonts/Arial.ttf') || die Imager->errstr();
mkdir $dir || die $!;
my @links;
my $image_num = 0;
my $frame_num = 0;


my $i = 2;
eval {
    my $last_img;
    DAY: foreach my $date (sort <20??????>) {
        my ($y,$m,$d) = unpack("A4 A2 A2", $date);
        my ($sunrise, $sunset) = Astro::Sunrise::sunrise($y,$m,$d, 138.731, 35.358, 9, 0, -.5);
        s/:// foreach ($sunrise, $sunset);

        FILE: foreach my $file (sort <$date/${date}_????_Web.jpg>) {

            my ($time) = ($file =~ m/_(\d{4})_/);
            #next FILE if $time < $sunrise;
            next FILE if $time < $sunset;

            print "$file\n";
            my $img = Imager->new(file => $file) or die Imager->errstr();
            #next unless check($img);
            $time =~ s/^(\d\d)/$1:/;

            #$img->filter(type=>'autolevels') || die $img->errstr();

            $img->string(
                font => $font, 
                text => "$y/$m/$d $time",
                x=>4, y=>728,
                color => 'white',
                size => 20,
                aa => 1
            );

            if ($last_img) {
                my $mid1 = $last_img->copy;
                $mid1->compose(src => $img, opacity => 0.5) || die $mid1->errstr();
                my $link = sprintf("$dir/%d.tiff", $frame_num++);
                print "Compose $link\n";
                $mid1->write(file => $link);
                push @links, $link;

            }

            $last_img = $img;
            $image_num++;
            next DAY;
        }
    }
    
    system("ffmpeg","-r","$rate","-sameq","-i","$dir/%d.tiff","test.mp4");
};
warn $@ if $@;

foreach my $link (@links) {
    unlink $link || warn "Unlink $link->[1]: $!";
}
rmdir $dir || warn "Rmdir $dir: $!";

