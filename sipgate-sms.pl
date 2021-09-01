#!/usr/bin/perl

#
# Nils Knieling: 2021/09/01, sipgate-sms.pl
#
# Send an SMS via the sipgate REST API
#
# sudo apt install libwww-perl libapp-options-perl libjson-xs-perl
#
# 1.) Order the free feature "SMS senden"
#    https://app.sipgatebasic.de/feature-store/sms-senden
#
# 2.) Get token id and token with 'sessions:sms:write' scope
#    https://app.sipgate.com/personal-access-token
#
# perl sipgate-sms.pl \
#    --id=YOUR_SIPGATE_TOKEN_ID \
#    --token=YOUR_SIPGATE_TOKEN \
#    --sms=YOUR_SIPGATE_SMS_EXTENSION_DEFAULT_S0 \
#    --tel=RECIPIENT_PHONE_NUMBER \
#    --msg="YOUR_MESSAGE"
#
# You can also create a sipgate-sms.conf configuration file in the same directory as the sipgate-sms.pl program with default values:
#
# id = YOUR_SIPGATE_TOKEN_ID
# token = YOUR_SIPGATE_TOKEN
# sms = YOUR_SIPGATE_SMS_EXTENSION_DEFAULT_S0
# tel = RECIPIENT_PHONE_NUMBER
# msg = YOUR_MESSAGE
#
# The token should have the sessions:sms:write scope.
# For more information about personal access tokens visit <https://www.sipgate.io/rest-api/authentication#personalAccessToken>.
#
# The smsId uniquely identifies the extension from which you wish to send your message.
# Further explanation is given in the section Web SMS Extensions <https://github.com/sipgate-io/sipgateio-sendsms-php#web-sms-extensions>.
#

use utf8;
binmode(STDOUT, ":utf8");
use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON::XS;
use App::Options (
	no_env_vars => 1,
	option => {
		id    => { required => 1, description => "Your sipgate token id (example: token-FQ1V12) " },
		token => { required => 1, description => "Your sipgate token (example: e68ead46-a7db-46cd-8a1a-44aed1e4e372)", secure => 1 },
		sms   => { required => 0, description => "Your sipgate SMS extension id (default: s0)", default => 's0' },
		tel   => { required => 1, description => "Phone number of the SMS recipient (example: 49157...)", type => "integer" },
		msg   => { required => 1, description => "SMS message" },
	},
);

# Create JSON for content body
my %json;
$json{smsId}     = $App::options{sms};
$json{recipient} = $App::options{tel};
$json{message}   = $App::options{msg};
# Convert Perl hash to JSON
my $json_text = encode_json \%json;

my $ua = LWP::UserAgent->new;
my $request = POST 'https://api.sipgate.com/v2/sessions/sms';
$request->authorization_basic($App::options{id}, $App::options{token});
$request->header( 'Content-Type' => 'application/json', 'Content-Length' => length($json_text) );
$request->content( $json_text );
my $response = $ua->request($request);

if ($response->is_success) {
	print "OK: Message sent successfully.\n";
} else {
	# Error codes: https://github.com/sipgate-io/sipgateio-sendsms-php#http-errors
	warn "ERROR: Message could not be sent! Status: '". $response->status_line ."'\n";
}
