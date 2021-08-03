#!/usr/bin/perl

###############################################################################
# Padlet Wish to Email Bot
# Nils Knieling: 2021/08/03, padlet_mail_bot.pl
###############################################################################

use utf8;
use strict;
use Encode qw(encode);
use LWP::UserAgent; # libwww-perl
use JSON::XS; # libjson-xs-perl
use Data::Dumper;
use HTML::FormatText::WithLinks; # libhtml-formattext-withlinks-perl
use Net::SMTP;
use MIME::Base64;

binmode(STDOUT, ":utf8");

###############################################################################
# CONFIG
###############################################################################

# Padlet wall ID
my $wall        = 'YOUR-ID'; #https://api.padlet.com/api/5/wishes?wall_id=
# Send new wishes (posts) to this email address
my $mailto      = 'nils@localhost';
# Debug output yes = 1, no = 0
my $debug = 1;

###############################################################################

my $mailserver  = 'localhost';
my $from        = 'no-reply@nkn-it.de';
my $name        = 'Padlet Bot';
my $mailfrom    = "\"$name\" <". $from .">";

###############################################################################

# MIME
my $type = qq ~
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: base64
~;

my $ua = LWP::UserAgent->new;
my $response = $ua->get("https://api.padlet.com/api/5/wishes?wall_id=$wall");

my $f = HTML::FormatText::WithLinks->new();

# Create dir for storage
my $first_run = 0;
unless (-d $wall) {
	unless(mkdir $wall) {
		die "Unable to create $wall\n";
	}
	$first_run = 1; # avoid many emails
}

# loop over the JSON API output
my $perl_scalar = JSON::XS->new->utf8->decode($response->content);
if ($perl_scalar->{'data'}) {
	print "✓ WALL: $wall\n";
	foreach my $data (@{$perl_scalar->{'data'}}) {
		#print Dumper($data);
		my $id        = $data->{'id'};
		my $subject   = $data->{'attributes'}->{'subject'} || "Without Subject";
		my $body      = $data->{'attributes'}->{'body'}    || "Without Text";
		my $text      = $f->parse($body);
		my $permalink = $data->{'attributes'}->{'permalink'} || "No Link";
		if ($debug) {
			print "ID:          $id \n";
			print "SUBJECT:     $subject \n";
			print "PERMALINK:   $permalink \n";
			print "BODY (HTML): $body \n";
			print "TEXT:\n$text \n";
		}
		# Create BASE64 text for email
		my $mail_text = "Link: $permalink\n\nSubject: $subject\nText:\n$text\n";
		my $base64 = encode_base64( encode("UTF-8", $mail_text ) );
		print "BASE64:\n$base64\n" if $debug;
		# New wish?
		unless (-f "$wall/$id") {
			print "» NEW WISH: $id\n";
			# Store JSON as file
			open(FH, '>', "$wall/$id") or die $!;
			print FH JSON::XS->new->utf8->encode($data);
			close(FH);
			# And send mail
			unless ($first_run) { 
				my $smtp = Net::SMTP->new($mailserver, Timeout => 60);
				$smtp->mail("no-reply\@localhost");
				$smtp->to($mailto);
				$smtp->data();
				$smtp->datasend("From: $mailfrom\n");
				$smtp->datasend("To: $mailto\n");
				$smtp->datasend("Subject: [Padlet] $subject");
				$smtp->datasend($type);
				$smtp->datasend("\n$base64");
				$smtp->dataend();
				$smtp->quit;
			}
		}
	}
} else {
	die('× Wall missing, no content or the endpoint has permanently moved.');
}