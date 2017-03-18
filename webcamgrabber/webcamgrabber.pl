#!/usr/bin/perl
#
# Web Cam Grabber
# Nils Knieling: 2004/08/06, webcamgrabber.pl
#
# This is a simple script to grab images from a webcam site.
# Enter URL of the webcam image, and this script does the rest.

use strict;
use LWP::Simple qw(mirror);
use File::Copy;
use Term::ANSIColor;
# Only Win32 system user
# use Win32::Console::ANSI;

###### USER VARIABLES START HERE ######
my $pic 	= 'http://cam:cam@160.0.4.99/jpg/image.jpg';
my $filetype 	= ".jpg";
# Arrive images in dir:
my $dir 	= 'E:/';
my $sleeptime 	= 10;
my $max 	= 1000;
# Arrive image only if size is bigger than $sensitive
my $sensitive	= 33040; # 0 = Off
###### USER VARIABLES END HERE ######

my $ver = '2004-08-06';

sub saveimg {
	my @date = localtime(time);
	$date[5] += 1900;
	$date[4] += 1;
	my $i; undef $i;
	for(@date) {
		if (/^\d{1}$/) {
			$date[$i] = "0$date[$i]";
		}
		$i++;
	}
	my @file = reverse(@date[0..5]);
	push(@file, $filetype);
	my $save = "$dir";
	foreach (@file) { $save .= $_ }
	print "$save - ";
	my $tmpsave = "$dir.temp.save$filetype";
	my $result = mirror("$pic", "$tmpsave");
	if ($result == 304) {
  		print color("red"), "No update needed\n", color("reset");
	} elsif ($result = 200) {
		my $size = (-s $tmpsave);
		if ($size > $sensitive) {
			print color("green"), "New image ($size) has arrived!\n", color("reset");
			copy("$tmpsave","$save") or die "Copy failed: $!";
		} else {
			print color("red"), "New image ($size) not arrived!\n", color("reset");
		}
	} else {
  		die "Bad mirror status: $result\n";
	}
}

print color("yellow"), "\nWeb Cam Grabber Version $ver\nAbort: CONTROL + C\n", color("reset");
unless ($dir =~ m~/$~) {
	print color("red"), "You forgot the trailing slash! Please correct \$dir.\n",  color("reset");
	exit(0);
}
for (my $i = 1; $i < $max; $i++) {
	&saveimg();
	sleep($sleeptime);
}
