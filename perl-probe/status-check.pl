#!/usr/bin/perl

# Copyright 2021 Nils Knieling. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Check destination

BEGIN {
	$VERSION = "1.0.0";
}

use utf8;
use strict;
use Digest::SHA qw(sha256_hex);


###############################################################################
# Options
###############################################################################

use App::Options (
	option => {
		cmd => {
			required    => 1,
			default     => 'ping',
			type        => '/^ping|nc|curl|grep|a|aaaa|ns|mx|txt$/',
			description => "Command to run. Can be 'ping', 'nc', 'curl', 'a', 'aaaa', 'ns', 'mx', 'txt'",
		},
		dest => {
			required    => 1,
			type        => '/^[\d\w\.\:\-\_\?\=\/\&]{1,255}$/',
			description => "Destination for the availability check (IP, Hostname or URL)",
		},
		opt => {
			required    => 0,
			type        => '/^[\d\w\.\:\-\_]{1,255}$/',
			description => "Port or grep text",
		},
		timeout => {
			required    => 0,
			default     => 5,
			type        => '/^[1-9]{1}[0-9]{0,1}$/',
			description => "Duration we wait for response (1-99)",
		},
		ping_count => {
			required    => 0,
			default     => 2,
			type        => '/^[1-9]{1}[0-9]{0,1}$/',
			description => "Stop ping after sending count ECHO_REQUEST packets (1-99)",
		},
		debug_options => {
			required    => 0,
			default     => 0,
			type        => 'boolean',
			description => "More output for debugging (1=on, 0=off)",
		},
	},
);

# Get user input
my $command     = $App::options{cmd};
my $destination = $App::options{dest};
my $option      = $App::options{opt};
my $timeout     = $App::options{timeout};
my $ping_count  = $App::options{ping_count};
my $debug       = $App::options{debug_options};


###############################################################################
# Create output file
###############################################################################

# Create random filename for output
my $digest    = sha256_hex( "$command,$option," .time()+int(rand(10000)) );
my $file_out  = '/tmp/'.$digest.'.out';

# Output for debuging
if ($debug) {
	print "User input:\n";
	print "\t Command: $command\n";
	print "\t Destination: $destination\n";
	print "\t Option: $option\n";
	print "File: $file_out\n";
}


###############################################################################
# Monitoring commands
###############################################################################

# Run command line programms and redirect output (STDOUT and STDERR) to file
my $return_text = '';
# ping (ICMP)
if ($command eq "ping") {
	# -n = Numeric output only. No attempt will be made to lookup symbolic names for host addresses.
	$return_text = qx(ping -n -w "$timeout" -c "$ping_count" "$destination" > $file_out 2>&1 && echo "OK");
}
# nc (TCP connection)
if ($command eq "nc") {
	$option = '80' if ($option !~ /^[1-9]{1}[0-9]{1,4}$/);
	print "Command: nc '$destination' '$option'\n" if $debug;
	$return_text = qx(nc -z -w "$timeout" "$destination" "$option"> $file_out 2>&1 && echo "OK");
}
# curl (HTTP)
if ($command eq "curl") {
	print "Command: curl '$destination'\n" if $debug;
	# -sS = silent but still show error messages
	$return_text = qx(curl -IsSf --max-time "$timeout" "$destination" > $file_out 2>&1 && echo "OK");
}
if ($command eq "grep") {
	$option = 'pong' if ($option !~ /^[\d\w\.\,]{1,128}$/ );
	print "Command: curl '$destination' | grep '$option'\n" if $debug;
	# -s = silent, quiet mode, mute curl. Do not show progress meter or error messages.
	qx(curl --no-buffer -fs --max-time "$timeout" "$destination" > $file_out 2>&1);
	$return_text = qx(grep "$option" "$file_out" > /dev/null 2>&1 && echo "OK");
}
# dig (DNS)
if ($command eq "a"    ||
	$command eq "aaaa" ||
	$command eq "ns"   ||
	$command eq "mx"   ||
	$command eq "txt"  ) {
	$option = '\.' if ($option !~ m{^[\d\w\.\:\-\_]{1,255}$} );
	print "Command: dig $command '$destination' | grep '$option'\n" if $debug;
	qx(timeout "$timeout" dig +short "$command" "$destination" > $file_out 2>&1);
	$return_text = qx(grep "$option" "$file_out" > /dev/null 2>&1 && echo "OK");
}


###############################################################################
# Read output file and check
###############################################################################

# Read output (STDOUT and STDERR)
open my $fh, q{<}, "$file_out";
sysread $fh, my $file_out_content, 2000; # read 2000 bytes of data into variable
close $fh;
# Delete file
unlink($file_out);
# Remove any trailing string
chomp($file_out_content);
print "File content:\n". $file_out_content ."\n" if $debug;

# Check output and generate value for metric
my $labels = "destination=$destination, option=$option";
if ( $return_text =~ /OK/ ) {
	print "UP: $command check on [ $labels ] has a normal state\n";
} else {
	die "DOWN: $command check on [ $labels ] is failing\nOutput:\n$file_out_content\n";
}