#!/usr/bin/perl

#
# Nils Knieling: 2021/08/15, sipgate-sms.pl
#
# Send an SMS via the sipgate RPC2 API
#
# Note: To send SMS, you need the "Send SMS" (German: "SMS-Senden") feature from the Feature Store.
#
# sudo apt install libfrontier-rpc-perl libapp-options-perl
#
# perl sipgate-sms.pl --user=USERNAME --pass=PASSWORD --tel=RECIPIENT --msg="MESSAGE"
#
# You can also create a sipgate-sms.conf configuration file in the same directory as the sipgate-sms.pl program with default values:
#
# user = USERNAME
# pass = PASSWORD
# tel = RECIPIENT
# msg = MESSAGE
#

use utf8;
binmode(STDOUT, ":utf8");
use strict;
use Frontier::Client;
use App::Options (
	no_env_vars => 1,
	option => {
		user => { required => 1, description => "User name for web access (not your SIP)" },
		pass => { required => 1, description => "Password (only letters and numbers)", secure => 1 },
		tel  => { required => 1, description => "Phone number of the SMS recipient (49157...)", type => "integer" },
		msg  => { required => 1, description => "SMS message" },
	},
);

my $url = 'https://'.$App::options{user}.':'.$App::options{pass}.'@api.sipgate.net/RPC2';
my $xmlrpc_client = Frontier::Client->new( 'url' => $url );
my $args_identify = { ClientName => 'sipgate-sms', ClientVersion => '1.0', ClientVendor => 'Cyclenerd' };
my $xmlrpc_identify = $xmlrpc_client->call( "samurai.ClientIdentify", $args_identify );
if ($xmlrpc_identify->{'StatusCode'} == 200) {
	my $args = { RemoteUri => 'sip:'.$App::options{tel}.'@sipgate.net', TOS => 'text', Content => $App::options{msg} };
	my $xmlrpc_result = $xmlrpc_client->call( "samurai.SessionInitiate", $args );
	if ($xmlrpc_result->{'StatusCode'} == 200) {
		print "✓ OK: SMS sent successfully.\n";
	} else {
		warn "× ERROR: SMS to ".$App::options{tel}." could not be sent!\n";
	}
} else {
	warn "× ERROR: Logon to sipgate was denied!\n";
}
