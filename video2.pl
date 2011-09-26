#!/usr/bin/env perl

# Simple video animation with handling of image resize after image format
# changed

use strict;
use warnings;
use Check;
use Astro::Sunrise;

my $dir  = "tmp";
my $rate = 24;
my $curve = 0;# 2;

my $font = Imager::Font->new(file => '/Library/Fonts/Arial Narrow.ttf') || die Imager->errstr();
mkdir $dir || die $!;
my @links;
my $image_num = 0;
my $frame_num = 0;


eval {
    my $last_img;
    foreach my $date (sort <20??????>) {
        my ($y,$m,$d) = unpack("A4 A2 A2", $date);
        my ($sunrise, $sunset) = Astro::Sunrise::sunrise($y,$m,$d, 138.731, 35.358, 9, 0, -10);
        s/:// foreach ($sunrise, $sunset);

        my $good = 0;
        my @images = ();
        foreach my $file (sort <$date/${date}_????_Web.jpg>) {

            my ($time) = ($file =~ m/_(\d{4})_/);
            next if $time < $sunrise;
            next if $time > $sunset;

            #print "$file\n";
            my $img = Imager->new(file => $file) or die Imager->errstr();
            $good++ if check($img);
            $time =~ s/^(\d\d)/$1:/;
            push @images, ["$y/$m/$d $time", $img];

        }
        warn "$date $good\n";
        if ($good > 20) {
            my $last_img;
            foreach my $pair (@images) {
                my ($str, $img) = @$pair;
                if ($img->getheight == 734) {
                    $img = $img->crop(top=>24,height=>685);
                    $img->string(
                        text => '(c)NTT DOCOMO, INC.  Yamanashi Branch', x=>725, y=>679,
                        font => $font, color => 'white', size => 18, aa => 1
                    );
                }
#print "$str\n";
                #$img->filter(type=>'autolevels') || die $img->errstr();
                $img->string(
                    text => $str, x=>4, y=>679,
                    font => $font, color => 'white', size => 22, aa => 1
                );

                if ($last_img) {
                    my $mid1 = $last_img->copy;
                    $mid1->compose(src => $img, opacity => 0.5) || die $mid1->errstr();
                    my $link = sprintf("$dir/%d.tiff", $frame_num++);
                    $mid1->write(file => $link);
                    push @links, $link;
                }
                $last_img = $img;

                my $link = sprintf("$dir/%d.tiff", $frame_num++);
                $img->write(file => $link);
                push @links, $link;


            }
        }
    }
    
    system("ffmpeg","-r","$rate","-sameq","-i","$dir/%d.tiff","test.mp4");
};
warn $@ if $@;

foreach my $link (@links) {
    unlink $link || warn "Unlink $link->[1]: $!";
}
rmdir $dir || warn "Rmdir $dir: $!";

