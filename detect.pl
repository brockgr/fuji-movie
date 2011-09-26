#!/usr/bin/perl

use strict;
use warnings;

use Image::Magick;

my $err;

# Edge detect the test image
my $test_image = Image::Magick->new;
$err = $test_image->Read($ARGV[0]);
die $err if $err;

$test_image->Edge(radius => 1);

my $kernel_image = Image::Magick->new;
$err = $kernel_image->Read('kernel.jpg');
die $err if $err;

#$err = $test_image->Convolve(coefficients => $kernel_image);
my $comp = $test_image->Compare(image => $kernel_image, metric => 'AE', fuzz => '10%');
my $SNRdelta = $comp->Get('error');
printf ("[ %f ]",$SNRdelta);

$comp->write("conv.jpg");
#$comp->Display();
#$test_image->Display();
#$kernel_image->Display();
