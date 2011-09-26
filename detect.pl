#!/usr/bin/perl

# Try to detect fuji through convolution

use strict;
use warnings;

use List::Util qw(sum);
use Image::Magick;


sub size {
    my ($image) = @_;
    return $image->Get('Width').'x'. $image->Get('height');
}

sub scale {
    my ($image) = @_;
    #$image->Set( Gravity => 'Center' );
    #$image->Resize( geometry => '64x64' );
    $image->Resize( geometry => '25%x25%' );
    #$image->Extent( geometry => '50%x50%' );

}

my $err;

# Edge detect the test image
my $test_image = Image::Magick->new;
$err = $test_image->Read($ARGV[0]);
die $err if $err;
#scale($test_image);


$test_image->Quantize(colorspace=>'gray');
$test_image->Edge(radius => 1);

#$test_image->Negate();
#$test_image->Display();


my $kernel_image = Image::Magick->new;
$err = $kernel_image->Read('kernel-crop.jpg');
die $err if $err;

$kernel_image->Quantize(colorspace=>'gray');
#scale($kernel_image);
#$kernel_image->Display();

#$err = $test_image->Convolve(coefficients => [1, 2, 1, 2, 4, 2, 1, 2, 1]);
#$err = $test_image->Convolve(coefficients => \@pixels);
$err = $kernel_image->Convolve(coefficients => [$test_image->GetPixels()]);
#$err = $test_image->Convolve(coefficients => $kernel_image);
#my $comp = $test_image->Compare(image => $kernel_image, metric => 'AE', fuzz => '50%');
#$comp->write("conv.jpg");
#my $SNRdelta = $comp->Get('error');
#printf ("[ %f ]",$SNRdelta);

#$comp->Display();
#$test_image->Display();
#$kernel_image->Display();
$kernel_image->Write('conv.jpg');

#my @pixels = $kernel_image->GetPixels();
#warn scalar @pixels;
#warn join ", ", @pixels[1000..1050];
#warn sum(@pixels) / @pixels;

my $sum =  my $pixels = 0;
my @histogram = $kernel_image->Histogram();
while (@histogram) {
    my ($red, $green, $blue, $opacity, $count) = splice(@histogram, 0, 5);
    #print sprintf "Red: 0x%04x. Green: 0x%04x. Blue: 0x%04x. Opacity: 0x%04x.  Count: %i. \n",
        #$red, $green, $blue, $opacity, $count;

    $red = 0xFFFF if $red < 0;

    $sum+=$red*$count;
    $pixels += $count;
}
die $sum/$pixels;
