#!/usr/bin/perl

#
# Nils Knieling: 2021/08/15, pushover.pl
#
# Send message via Pushover API (https://pushover.net/api)
#
# sudo apt install libwww-perl libapp-options-perl
#
# perl pushover.pl --user=USER --token=TOKEN --msg="MESSAGE"
#
# You can also create a pushover.conf configuration file in the same directory as the pushover.pl program with default values:
#
# user = USER
# token = TOKEN
# msg = MESSAGE
#

use utf8;
binmode(STDOUT, ":utf8");
use strict;
use LWP::UserAgent;
use App::Options (
	no_env_vars => 1,
	option => {
		user  => { required => 1, description => "The user/group key (not e-mail address) of your user" }, # viewable when logged into our dashboard
		token => { required => 1, description => "Your application's API token ", secure => 1 },
		msg   => { required => 1, description => "Your message" },
	},
);

my $response = LWP::UserAgent->new()->post(
	"https://api.pushover.net/1/messages.json", [
	"token"   => $App::options{token},
	"user"    => $App::options{user},
	"message" => $App::options{msg},
]);

if ($response->is_success) {
	print "OK: Message sent successfully.\n";
} else {
	warn "ERROR: Message could not be sent!\n";
}
