package Check;

# Library for naive check for image quality based on averaging lines
# of pixels

use strict;
use warnings;
use Imager;

use base qw(Exporter);
our @EXPORT = qw(check);

my $threshold = 40;

# Horizontal lines to test, keyed by y offset.
# Lines are start=>stop for light-dark-light
my %regions = (
    222 => [ 473 => 516, 539 => 589, 615 => 670 ],
    240 => [ 420 => 480, 505 => 620, 645 => 720 ],
    260 => [ 400 => 445, 470 => 660, 690 => 760 ],
);

sub average_rgb ($$$$) {
    my ($img, $y, $x1, $x2) = @_;
    my ($total, $count);

    for my $x ($x1..$x2) {
        my @rgb = $img->getpixel(x => $x, y => $y)->rgba;

        # Value per pixel if 50% red, 50% green, 0% blue
        $total += ($rgb[0]+$rgb[1]) / 2;

        $count++;
    }

    return int $total/$count;
}

sub check {
    my ($img) = @_;
    my $score = 0;
    while (my ($y, $xs) = each %regions) {
        my $val1 = average_rgb($img, $y, $xs->[0], $xs->[1]);
        my $val2 = average_rgb($img, $y, $xs->[2], $xs->[3]);
        my $val3 = average_rgb($img, $y, $xs->[4], $xs->[5]);
        ($val1-$val2) > $threshold && $score++;
        ($val3-$val2) > $threshold && $score++;
        return 1 if $score > 1;
    }
    return;
}

