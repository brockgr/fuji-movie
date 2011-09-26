#!/usr/bin/perl

# Animation based on naive image check and sunrise/set times

use strict;
use warnings;
use Check;
use Astro::Sunrise;

my $dir  = "tmp";
my $rate = 30;
my $curve = 0;# 2;

my $font = Imager::Font->new(file => '/Library/Fonts/Arial.ttf') || die Imager->errstr();
mkdir $dir || die $!;
my @links;
my $image_num = 0;
my $frame_num = 0;


my $i = 2;
my $extra = 0;
my @extra = ();
while ($extra < $rate*$curve) {
    $i *= 1.1;
    $extra += int($i);
    push @extra, int($i);
}
warn "@extra";
#die $extra;
    
eval {
    my $last_img;
    foreach my $date (sort <200910??>) {
        my ($y,$m,$d) = unpack("A4 A2 A2", $date);
        my ($sunrise, $sunset) = Astro::Sunrise::sunrise($y,$m,$d, 138.731, 35.358, 9, 0, 0);
        s/:// foreach ($sunrise, $sunset);

        foreach my $file (sort <$date/${date}_????_Web.jpg>) {

            my ($time) = ($file =~ m/_(\d{4})_/);
            next if $time < $sunrise;
            next if $time > $sunset;

            print "$file\n";
            my $img = Imager->new(file => $file) or die Imager->errstr();
            next unless check($img);
            $time =~ s/^(\d\d)/$1:/;

            $img->filter(type=>'autolevels') || die $img->errstr();

#            $img = Imager::transform2({
#                    rpnexpr => 'x y getp1 !pix @pix hue @pix sat 1.5 * @pix value hsv ',
#            }, $img) || die Imager->errstr();    

#$img->write(file => "/tmp/1.tiff");
#system("open $file /tmp/1.tiff");
#exit;
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

            my $loop = $image_num < @extra ? $extra[@extra - $image_num - 1] : 1;
            for (1..$loop) {
                my $link = sprintf("$dir/%d.tiff", $frame_num++);
                print "Link $file -> $link\n";
                $img->write(file => $link);
                push @links, $link;
            }
            $last_img = $img;

            $image_num++;
        }
    }
    $frame_num -= @extra;
    
    if (@extra) {
        my @final = splice @links, (0-@extra);
        foreach my $link (@final) {
            rename ($link, "$link.bak") || die "Rename [$link] [$link.bak]: $!";
            push @links, "$link.bak";
        }
    
    warn "Extra ".@extra;
    warn "Final ".@final;
        for (my $n=0; $n<@final; $n++) {
            my $loop = $extra[$n];
            my $orig = $final[$n];
            for (1..$loop) {
                my $link = sprintf("$dir/%d.tiff", $frame_num++);
                print "Relink $orig.bak -> $link\n";
                link("$orig.bak",$link) || die $!;
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

