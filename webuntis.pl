#!/usr/bin/perl

# Copyright 2024 Nils Knieling
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# WebUntis Bot
# Get notified when there is a change in the school schedule.

# Debian:
# sudo apt update && \
# sudo apt install \
#  libapp-options-perl \
#  libdigest-sha-perl \
#  libwww-perl \
#  libjson-xs-perl
# curl -O "https://raw.githubusercontent.com/Cyclenerd/toolbox/master/webuntis.pl"
# perl webuntis.pl --help

BEGIN {
	$VERSION = "1.1.0";
}

use utf8;
use strict;
use warnings;
use Data::Dumper;
use Digest::SHA qw(sha256_hex);
use Encode;
use HTML::Entities;
use HTTP::Request::Common;
use JSON::XS;
use LWP::UserAgent;
use POSIX qw(strftime);
use App::Options (
	option => {
		school => { type => "string", required => 1, description => "WebUntis School ID [required]" },
		class  => { type => "string", required => 1, description => "Filter class aka group ID [required]" },
		class2 => { type => "string", required => 0, description => "Filter 2nd class aka group ID [optional]" },
		offset => { type => "int",    required => 1, description => "Date offset, look into the future [default: 0]", default => 0 },
		key    => { type => "string", required => 0, description => "The Pushover key (not e-mail address) of your user or group [optional]" },
		token  => { type => "string", required => 0, description => "Your application's API token [optional]", secure => 1 },
	},
);

binmode(STDOUT, ":utf8");

my $inputSchool        = $App::options{school} || "";
my $inputClass         = $App::options{class}  || "";
my $inputClass2        = $App::options{class2} || "";
my $inputDateOffset    = $App::options{offset} || "0";
my $inputPushoverKey   = $App::options{key}    || "";
my $inputPushoverToken = $App::options{token}  || "";

print "Class: $inputClass\n";
print "2nd Class: $inputClass2\n" if $inputClass2;

# Backslash non-"word" ASCII characters for safer regex
my $filterClass  = quotemeta($inputClass);
my $filterClass2 = quotemeta($inputClass2);

my $today = strftime "%Y%m%d", localtime;

# WebUntis JSON message body
# Source: https://ikarus.webuntis.com/WebUntis/monitor?school=[SCHOOL-ID]&monitorType=subst&format=SchuelerZweiTage
my $body = qq ~
{
	"formatName": "SchuelerZweiTage",
	"schoolName": "$inputSchool",
	"date": $today,
	"dateOffset": $inputDateOffset,
	"strikethrough": true,
	"mergeBlocks": true,
	"showOnlyFutureSub": true,
	"showBreakSupervisions": false,
	"showTeacher": true,
	"showClass": true,
	"showHour": true,
	"showInfo": true,
	"showRoom": true,
	"showSubject": true,
	"groupBy": 1,
	"hideAbsent": false,
	"departmentIds": [],
	"departmentElementType": -1,
	"hideCancelWithSubstitution": true,
	"hideCancelCausedByEvent": false,
	"showTime": false,
	"showSubstText": true,
	"showAbsentElements": [],
	"showAffectedElements": [],
	"showUnitTime": true,
	"showMessages": true,
	"showStudentgroup": false,
	"enableSubstitutionFrom": true,
	"showSubstitutionFrom": 0,
	"showTeacherOnEvent": false,
	"showAbsentTeacher": true,
	"strikethroughAbsentTeacher": true,
	"activityTypeIds": [],
	"showEvent": true,
	"showCancel": true,
	"showOnlyCancel": false,
	"showSubstTypeColor": false,
	"showExamSupervision": false,
	"showUnheraldedExams": false
}
~;

print "Get WebUnits data...\n";
my $ua = LWP::UserAgent->new;
my $request = POST "https://ikarus.webuntis.com/WebUntis/monitor/substitution/data?school=$inputSchool";
$request->header('Content-Type' => 'application/json','Content-Length' => length($body));
$request->content($body);
my $response = $ua->request($request);
unless ($response->is_success) {
	die "ERROR: Cannot access WebUnits API! Status: '". $response->status_line ."'\n";
}

my $json = JSON::XS->new->utf8->decode($response->content);
my $payload = $json->{'payload'} or die "ERROR: No data (payload) in JSON!";
my $lastUpdate = $payload->{'lastUpdate'} or die "ERROR: Last update date missing!\n";
my $date = $payload->{'date'} or die "ERROR: Date missing!\n";
die "ERROR: Date '$date' invalid!\n" unless ($date =~ /\d{4}\d{2}\d{2}/);
my $weekDay = $payload->{'weekDay'} or die "ERROR: Day of week missing!\n";
print "Date: $date\n";
print "Day: $weekDay\n";
print "Last update: $lastUpdate\n";
#print Dumper($json);
my @texts;
foreach my $row (@{$payload->{'rows'}}) {
	my $group = $row->{'group'} || "";
	my %cells;
	# hour    0
	# class   1
	# subject 2
	# room    3
	# teacher 4
	# info    5
	# text    6
	foreach my $cell (0..6) {
		$cells{$cell} = $row->{'data'}[$cell] || "";
		# Remove HTML elements
		$cells{$cell} =~ s|<span class="substMonitorSubstElem">|⚠️ |g;
		$cells{$cell} =~ s|<span class="cancelStyle">|❌ |g;
		$cells{$cell} =~ s|<span class="[\d\w]+">||g;
		$cells{$cell} =~ s|</span>||g;
		$cells{$cell} = decode_entities($cells{$cell});
	}
	my $class = $cells{'1'};
	# Skip if class from input not found
	if ($filterClass2) {
		unless ($group =~ /$filterClass/i || $group =~ /$filterClass2/i) {
			next;
		}
	} else {
		unless ($group =~ /$filterClass/i) {
			next;
		}
	}
	# Check if complete cell value is canceled
	if ($row->{'cellClasses'}) {
		foreach my $cell (keys %cells) {
			if ($row->{'cellClasses'}->{$cell}) {
				foreach $class (@{$row->{'cellClasses'}->{$cell}}) {
					if ($class =~ /cancel/) {
						$cells{$cell} = "❌ ". $cells{$cell};
					}
				}
			}
		}
	}
	my $hour = $cells{'0'} || "???";
	# Format hours for better sort
	if ($hour =~ /^(\d+)$/) { $hour = sprintf("%#.2d", $1) }
	if ($hour =~ /^(\d+) - (\d+)$/) { $hour = sprintf("%#.2d - %#.2d", $1, $2) }
	my $text  = sprintf("<b>%s</b>", $hour);
	   $text .= sprintf(", %s", $cells{'2'}) if $cells{'2'};
	   $text .= sprintf(", %s", $cells{'3'}) if $cells{'3'};
	   $text .= sprintf(", %s", $cells{'4'}) if $cells{'4'};
	   $text .= sprintf(", <i>%s</i>", $cells{'5'}) if $cells{'5'};
	   $text .= sprintf(", <i>%s</i>", $cells{'6'}) if $cells{'6'};
	push(@texts, "$text");
}
# Sort text
my $message;
foreach my $text (sort @texts) {
	print "$text\n";
	$message .= "$text\n\n";
}

# Hash message to avoid duplicate notifications
my $messageHash = sha256_hex(encode_utf8("$date $message"));

# Notify via Pushover
if ($inputPushoverKey && $inputPushoverToken && $message && $messageHash) {
	my $filenameLastMessage = "/tmp/webuntis.$inputSchool.last.message.txt";
	my $lastMessageHash = "";
	if (-f $filenameLastMessage ) {
		open(my $fhLastMessage, '<', $filenameLastMessage);
		$lastMessageHash = <$fhLastMessage>;
		close($fhLastMessage);
	}
	# Check last message
	if ($lastMessageHash && $lastMessageHash eq $messageHash) {
		print "SKIP: Already notified. No change to the last run.";
	} else {
		print "Notify via Pushover...\n";
		my %post = (
			"token"     => $inputPushoverToken,
			"user"      => $inputPushoverKey,
			"title"     => $weekDay,
			"message"   => $message,
			"html"      => "1",
			"url"       => "https://ikarus.webuntis.com/WebUntis/monitor?school=$inputSchool&monitorType=subst&format=SchuelerZweiTage",
			"url_title" => "WebUntis"
		);
		my $pushover = LWP::UserAgent->new()->post(
			"https://api.pushover.net/1/messages.json", \%post
		);
		if ($pushover->is_success) {
			print "OK: Message sent successfully.\n";
			open(my $fhThisMessage, '>', "/tmp/webuntis.$inputSchool.last.message.txt");
			print $fhThisMessage "$messageHash";
			close($fhThisMessage);
		} else {
			die "ERROR: Message could not be sent! Status: '". $response->status_line ."'\n";
		}
	}
}
