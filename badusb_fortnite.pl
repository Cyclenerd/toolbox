#!/usr/bin/perl

# Creates a BadUSB scipt to simulate keyboard operation for Fortnite with Flipper Zero
#
# perl badusb_fornite.pl > fornite.txt
#
# https://developer.flipper.net/flipperzero/doxygen/badusb_file_format.html

use strict;

my @keys = ('CONTROL', 'SPACE', 'STRING f', 'STRING 1', 'STRING 2', 'STRING 3', 'STRING 4', 'STRING 5');
my $key_count = $#keys;
my $min_ms = 3 * 60 * 1000;
my $max_ms = 5 * 60 * 1000;

foreach my $key (@keys) {
	print "DELAY 2000\n";
	print "$key\n";
}

foreach my $i (0..1000) {
	my $random_ms = $min_ms + int(rand($max_ms - $min_ms));
	# Delay value in ms
	print "DELAY $random_ms\n";
	my $random_key = $keys[int(rand($key_count))];
	print "$random_key\n";
}