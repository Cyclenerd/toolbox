#!/usr/bin/perl

# scp-html5-bot.pl
# Author: Nils Knieling
#    https://github.com/Cyclenerd/toolbox/blob/master/sap/scp-html5-bot.pl
#
###################################################################################################
#
# The missing CLI for SAP Cloud Platform HTML5 Applications.
# With this Perl script you can upload and activate a version of an HTML5 App.
#
###################################################################################################
#
# Examples:
#    Activate only:       perl scp-html5-bot.pl -a abc123 -u S0001 -b demo -v one
#    Upload and activate: perl scp-html5-bot.pl -a abc123 -u S0001 -b demo -v two -i MyApp.zip
#
###################################################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
###################################################################################################

use strict;
use utf8;
use LWP::UserAgent; # install also LWP::Protocol::https
use HTTP::Cookies;
use HTTP::Request::Common;
use JSON;
use Getopt::Long;
use Term::ReadKey;
#use Data::Dumper;

# Get command line options
my ($account_id, $user, $password, $app_name, $app_version, $file, $trial, $debug, $help);
GetOptions (
	"account|a=s" => \$account_id,      # SAP Cloud subaccount name (ID) [string]
	"user|u=s" => \$user,               # Username or email [string]
	"password|pass|p=s" => \$password,  # Password [string]
	"application|b=s" => \$app_name,    # HTML5 app name [string]
	"version|tag|v=s" => \$app_version, # HTML5 app version tag [string]
	"import|zip|i=s" => \$file,         # Import HTML5 app version from ZIP file [string]
	"trial|t" => \$trial,               # Neo or Trail? [flag]
	"debug|d" => \$debug,               # Debug? [flag]
	"help|?|h" => \&usage)              # Help? [flag]
or die("Error in command line arguments\n");

# Uniform Resource Identifiers
my $root_uri = $trial ? 'https://account.hanatrial.ondemand.com' : 'https://account.hana.ondemand.com';
# Cockpit
# NEO:   https://account.hana.ondemand.com/cockpit
# TRIAL: https://account.hanatrial.ondemand.com/cockpit
my $cockpit_uri = $root_uri . '/cockpit';
# AJAX
my $ajax_uri = $root_uri . '/ajax';

# Location for cookie file
my $cookies = "cookies.txt";

# Create web browser
my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0, 'SSL_verify_mode' => 'SSL_VERIFY_NONE' } );
$ua->agent('SAPCloudBot/1.0');
# Store cookies
my $cookie_jar = HTTP::Cookies->new( file => $cookies, tosave => 1, ignore_discard => 1 );
$ua->cookie_jar($cookie_jar);


#
# HELPER
#

# Print usage and exit
sub usage {
	print "usage: $0 -a SUBACCOUNT NAME -u USERNAME -p PASSWORD -b APP NAME -v APP VERSION [-i IMPORT-HTML5-FILE.ZIP] [-t] [-d]\n\n";
	print "\t -a, --account          : Subaccount name\n";
	print "\t -u, --user             : Use your email, SAP ID or user name\n";
	print "\t -p, --pass, --password : To protect your password, enter it only when prompted by the console client and not explicitly as a parameter\n";
	print "\t -b, --application      : The name of the HTML5 application\n";
	print "\t -v, --version, --tag   : The version tag of the HTML5 application\n";
	print "\t -i, --import, --zip    : Import HTML5 app version from ZIP file\n";
	print "\t -t, --trial            : Use trial account [Europe (Rot) - Trial]\n";
	print "\t -d, --debug            : Output for debugging\n";
	print "\n";
	exit 1;
}

# Delete cookies
sub delCookies {
	$cookie_jar->clear();
}


# Login to SAP Cloud
my ($sap_token, $spId, $xsrfProtection, $authenticity_token, $csrftoken);
sub login {
	print "\nLOGIN ($user)\n";
	
	my ($SAMLRequest, $RelayState, $SAMLResponse);
	
	# Get SAML request
	my $saml_request = $ua->get( $cockpit_uri )
		or die "Unable to GET SAML request: $!";
	if ($saml_request->content =~ /SAMLRequest" value="([\d\w+\/=]*)"/g) {
		$SAMLRequest = $1;
		print "SAMLRequest: $SAMLRequest\n" if $debug;
	}
	if ($saml_request->content =~ /RelayState" value="([\d\w+\/=]*)"/g) {
		$RelayState = $1;
		print "RelayState: $RelayState\n" if $debug;
	}
	
	# Login
	my $saml_login = $ua->post( 'https://accounts.sap.com/saml2/idp/sso/accounts.sap.com', [ 
		'SAMLRequest' => $SAMLRequest,
		'RelayState'  => $RelayState,
	] ) or warn "Unable to POST SAML request: $!";
	if ($saml_login->content =~ /spId' type='hidden' value='([\d\w]*)'/g) {
		$spId = $1;
		print "spId: $spId\n" if $debug;
	}
	if ($saml_login->content =~ /xsrfProtection" value="([\d\w+\/=]*)"/g) {
		$xsrfProtection = $1;
		print "xsrfProtection: $xsrfProtection\n" if $debug;
	}
	if ($saml_login->content =~ /authenticity_token" value="([\d\w+\/=]*)"/g) {
		$authenticity_token = $1;
		print "authenticity_token: $authenticity_token\n" if $debug;
	}
	
	# Login and get SAML response
	my $saml_spName = $trial ? 'https://nwtrial.ondemand.com/services' : 'https://netweaver.ondemand.com/services';
	my $saml_response = $ua->post( 'https://accounts.sap.com/saml2/idp/sso/accounts.sap.com', [ 
		'mobileSSOToken'     => '',
		'tfaToken'           => '',
		'css'                => '',
		'targetUrl'          => '',
		'sourceUrl'          => '',
		'org'                => '',
		'utf8'               => '✓',
		'method'             => 'POST',
		'idpSSOEndpoint'     => 'https://accounts.sap.com/saml2/idp/sso/accounts.sap.com',
		'spName'             => $saml_spName,
		'spId'               => $spId,
		'authenticity_token' => $authenticity_token,
		'xsrfProtection'     => $xsrfProtection,
		'SAMLRequest'        => $SAMLRequest,
		'RelayState'         => $RelayState,
		'j_username'         => $user,
		'j_password'         => $password,
	] ) or warn "Unable to POST SAML login and get response: $!";
	if ($saml_response->content =~ /SAMLResponse" value="([\d\w+\/=]*)"/g) {
		$SAMLResponse = $1;
		print "SAMLResponse: $SAMLResponse\n" if $debug;
	}
	if ($saml_response->content =~ /RelayState" value="([\d\w+\/=]*)"/g) {
		$RelayState = $1;
		print "RelayState: $RelayState\n" if $debug;
	}
	#print $saml_response->content;
	
	my $login = $ua->post( $cockpit_uri, [ 
		'utf8'               => '✓',
		'authenticity_token' => $authenticity_token,
		'SAMLResponse'       => $SAMLResponse,
		'RelayState'         => $RelayState,
	] ) or warn "Unable to POST SAML login: $!";
	#print $login->content;
	if ($login->content =~ m|<title>Missing Authorization</title>|g) {
		print "\nLogin failed!\n";
		exit 9;
	}
	
	my $cockpit = $ua->get( $cockpit_uri )
		or die "Unable to GET cockpit: $!";
	#print $cockpit->content;
	# include the X-ClientSession-ID in /ajax calls !!!11
	if ($cockpit->content =~ /csrftoken="([\d\w-]*)"/g) {
		$csrftoken = $1;
		print "csrftoken: $csrftoken\n" if $debug;
	}
}


sub importHtml5Application {
	print "\nIMPORT ($file) HTML5 App ($app_name) Version Tag ($app_version)\n";
	
	# .../importHtml5Application/<ACCOUNT>/<APP-NAME>/<GIT-VERSION-TAG>
	my $importApp_uri = "$ajax_uri/importHtml5Application/$account_id/$app_name/$app_version".'?X-ClientSession-Id='."$csrftoken";
	my $importApp_req  = HTTP::Request::Common::POST( 
		$importApp_uri,
		# Content-Disposition: form-data; name="Html5FileImporter"; filename="scp_neo_html5_static.zip"
		'Content_Type' => 'multipart/form-data',
		'Content' => [ 
			'Html5FileImporter' => [$file, 'upload.zip']
		]
	);
	my $importApp = $ua->request( $importApp_req ) or warn "Unable to POST importHtml5Application: $!";
	print $importApp->content if $debug;
	if ($importApp->content =~ /Created/g) {
		print "\nImport successful!\n";
	} elsif ($importApp->content =~ /exists/g) { # <html><head></head><body>[409]:Version already exists</body></html>
		print "\nVersion already exists!\n";
		exit 8;
	} else {
		print "\nImport with errors!\n";
		exit 8;
	}
}


sub activateTag {
	print "\nACTIVATE HTML5 App ($app_name) Version Tag ($app_version)\n";
	
	# .../triggerHtml5AppVersionAction/<ACCOUNT>/<APP-NAME>/<GIT-VERSION-TAG>
	my $activateTag_uri = "$ajax_uri/triggerHtml5AppVersionAction/$account_id/$app_name/$app_version";
	my $activateTag_req  = HTTP::Request->new( 'POST', $activateTag_uri);
	$activateTag_req->content('ACTIVATE');
	$activateTag_req->header( 
		'Content-Type'       => 'application/json',
		'X-Requested-With'   => 'XMLHttpRequest',
		'X-ClientSession-Id' => $csrftoken,
		'Referer'            => $cockpit_uri,
	);
	my $activateTag = $ua->request( $activateTag_req ) or warn "Unable to POST triggerHtml5AppVersionAction: $!";
	print $activateTag->content if $debug;
	# {"message": "Application does not exist"}
	if ($activateTag->content =~ /Application does not exist/g) {
		print "\nApplication name does not exist!\n";
		exit 8;
	}
	if ($activateTag->content =~ /Version not found/g) {
		print "\nVersion tag not found!\n";
		exit 8;
	}
	sleep(3);
	
	print "\nRESTART HTML5 App ($app_name)\n";
	
	# .../triggerHtml5AppAction/<ACCOUNT>/<APP-NAME>
	my $restartApp_uri = "$ajax_uri/triggerHtml5AppAction/$account_id/$app_name";
	my $restartApp_req  = HTTP::Request->new( 'POST', $restartApp_uri );
	$restartApp_req->content('RESTART');
	$restartApp_req->header( 
		'Content-Type'       => 'application/json',
		'X-Requested-With'   => 'XMLHttpRequest',
		'X-ClientSession-Id' => $csrftoken,
		'Referer'            => $cockpit_uri,
	);
	my $restartApp = $ua->request( $restartApp_req ) or warn "Unable to POST triggerHtml5AppAction: $!";
	print $restartApp->content if $debug;
	sleep(3);
	
	print "\nGET HTML5 App Versions ($app_name)\n";
	
	# .../getAllHtml5AppVersions/<ACCOUNT>/<APP-NAME>
	my $getAllHtml5AppVersions_uri = "$ajax_uri/getAllHtml5AppVersions/$account_id/$app_name";
	my $getAllHtml5AppVersions_req  = HTTP::Request->new( 'GET', $getAllHtml5AppVersions_uri );
	$getAllHtml5AppVersions_req->header( 
		'Content-Type'       => 'application/json',
		'X-Requested-With'   => 'XMLHttpRequest',
		'X-ClientSession-Id' => $csrftoken,
		'Referer'            => $cockpit_uri,
	);
	my $getAllHtml5AppVersions = $ua->request( $getAllHtml5AppVersions_req ) or warn "Unable to GET getAllHtml5AppVersions: $!";
	print $getAllHtml5AppVersions->content if $debug;
	
	my $getAllHtml5AppVersions_json = from_json( $getAllHtml5AppVersions->content );
	#print Dumper($getAllHtml5AppVersions_json);
	#$VAR1 = [
	# {
	#  'isActiveVersion' => bless( do{\(my $o = 1)}, 'JSON::PP::Boolean' ),
	#  'author' => 'Nils Knieling',
	#  'version' => '1.0.1',
	#  'commitId' => '7a09305dca4c3a521fe5dd7103d3749260cc74e0',
	#  'authoredTimeRelative' => '7 months ago',
	#  'isActive' => $VAR1->[0]{'isActiveVersion'},
	#  'url' => 'https://static-s0009028968trial.dispatcher.hanatrial.ondemand.com?hc_commitid=7a09305dca4c3a521fe5dd7103d3749260cc74e0',
	#  'authoredTime' => '1504088736000'
	# },
	# {
	#  'commitId' => 'f1a4f341ed561448cca59c4159fb6d4d19772965',
	#  'version' => '1.0.0',
	#  'author' => 'Nils Knieling',
	#  'isActiveVersion' => bless( do{\(my $o = 0)}, 'JSON::PP::Boolean' ),
	#  'authoredTimeRelative' => '7 months ago',
	#  'isActive' => $VAR1->[1]{'isActiveVersion'},
	#  'authoredTime' => '1502699008000',
	#  'url' => 'https://static-s0009028968trial.dispatcher.hanatrial.ondemand.com?hc_commitid=f1a4f341ed561448cca59c4159fb6d4d19772965'
	# }
	#];
	
	print "\n";
	my $okily_dokily = 0;
	foreach my $version ( @{$getAllHtml5AppVersions_json} ) {
		print $version->{version} . "\n";
		print "\t isActive: " . $version->{isActive} . "\n";
		print "\t isActiveVersion: " . $version->{isActiveVersion} . "\n";
		if ($version->{version} eq $app_version) {
			if ($version->{isActiveVersion}) {
				$okily_dokily = 1;
				print "\t OK!\n"
			}
		}
	}
	unless ($okily_dokily) {
		print "\nUnable to activate version tag!\n";
		exit 8;
	}
}

sub startApp {
	print "\nSTART HTML5 App ($app_name)\n";
	
	# .../triggerHtml5AppAction/<ACCOUNT>/<APP-NAME>
	my $startApp_uri = "$ajax_uri/triggerHtml5AppAction/$account_id/$app_name";
	my $startApp_req  = HTTP::Request->new( 'POST', $startApp_uri);
	$startApp_req->content('START');
	$startApp_req->header( 
		'Content-Type'       => 'application/json',
		'X-Requested-With'   => 'XMLHttpRequest',
		'X-ClientSession-Id' => $csrftoken,
		'Referer'            => $cockpit_uri,
	);
	my $startApp = $ua->request( $startApp_req ) or warn "Unable to POST triggerHtml5AppAction: $!";
	print $startApp->content if $debug;
	
	print "\nWaiting...\n";
	sleep(3);
	my $getHtml5AppDetails_uri = "$ajax_uri/getHtml5AppDetails/$account_id/$app_name";
	while() {
		print "\n";
		my $getHtml5AppDetails_req  = HTTP::Request->new( 'GET', $getHtml5AppDetails_uri );
		$getHtml5AppDetails_req->header( 
			'Content-Type'       => 'application/json',
			'X-Requested-With'   => 'XMLHttpRequest',
			'X-ClientSession-Id' => $csrftoken,
			'Referer'            => $cockpit_uri,
		);
		my $getHtml5AppDetails = $ua->request( $getHtml5AppDetails_req ) or warn "Unable to GET getHtml5AppDetails: $!";
		print $getHtml5AppDetails->content if $debug;
		# name			static
		# displayName		static
		# secureAccessViaRoute	true
		# activeVersion		1.0.1
		# activeCommit		7a09305dca4c3a521fe5dd7103d3749260cc74e0
		# isActiveCommitCurrent	true
		# startedVersion	1.0.1
		# startedCommit		7a09305dca4c3a521fe5dd7103d3749260cc74e0
		# status		STARTED
		# repository		https://git.hanatrial.ondemand.com/s0009028968trial/static
		# url			https://static-s0009028968trial.dispatcher.hanatrial.ondemand.com
		my $status = '';
		if ($getHtml5AppDetails->content =~ /status":"([\d\w]*)"/g) {
			$status = $1;
			print "getHtml5AppDetailsAccount status: $status\n";
		}
		if ($status eq 'STARTED') {
			last; # done
		}
		sleep(15); # wait 15 sec
	}
}

sub stopApp {
	print "\nSTOP HTML5 App ($app_name)\n";
	
	my $stopApp_uri = "$ajax_uri/triggerHtml5AppAction/$account_id/$app_name";
	my $stopApp_req  = HTTP::Request->new( 'POST', $stopApp_uri );
	$stopApp_req->content('STOP');
	$stopApp_req->header( 
		'Content-Type'       => 'application/json',
		'X-Requested-With'   => 'XMLHttpRequest',
		'X-ClientSession-Id' => $csrftoken,
		'Referer'            => $cockpit_uri,
	);
	my $stopApp = $ua->request( $stopApp_req ) or warn "Unable to POST triggerHtml5AppAction: $!";
	print $stopApp->content if $debug;
	
	print "\nWaiting...\n";
	sleep(3);
	my $getHtml5AppDetails_uri = "$ajax_uri/getHtml5AppDetails/$account_id/$app_name";
	while() {
		print "\n";
		my $getHtml5AppDetails_req  = HTTP::Request->new( 'GET', $getHtml5AppDetails_uri );
		$getHtml5AppDetails_req->header( 
			'Content-Type'       => 'application/json',
			'X-Requested-With'   => 'XMLHttpRequest',
			'X-ClientSession-Id' => $csrftoken,
			'Referer'            => $cockpit_uri,
		);
		my $getHtml5AppDetails = $ua->request( $getHtml5AppDetails_req ) or warn "Unable to GET getHtml5AppDetails: $!";
		print $getHtml5AppDetails->content if $debug;
		my $status = '';
		if ($getHtml5AppDetails->content =~ /status":"([\d\w]*)"/g) {
			$status = $1;
			print "getHtml5AppDetailsAccount status: $status\n";
		}
		if ($status eq 'STOPPED') {
			last; # done
		}
		sleep(15); # wait 15 sec
	}
}

#
# MAIN
#

if ($trial) {
	print "\nSAP Cloud Platform Trial\n";
}
# Check input quickly
unless ($account_id) {
	print "SAP Cloud subaccount name (ID) missing!\n";
	&usage();
}
unless ($user) {
	print "Username or email missing!\n";
	&usage();
}
unless ($app_name) {
	print "HTML5 app name missing!\n";
	&usage();
}
unless ($app_version) {
	print "HTML5 app version missing!\n";
	&usage();
}
if ($file) {
	unless (-f $file) {
		print "\"$file\" not found or is not a plain file!\n";
		exit 2;
	}
	unless ($file =~ /\.zip$/i ) {
		print "\"$file\" must be a ZIP file!\n";
		exit 2;
	}
}
if ($user && !$password) {
	print "Password: ";
	ReadMode 'noecho';
	$password = <STDIN>; 
	ReadMode 'original';
	chomp($password);
	print "\n";	
}

&delCookies(); # Clear cookies
&login(); # Try to login
&importHtml5Application() if ($file); # Import HTML5 app from ZIP file
&activateTag(); # Try to activate version tag
&delCookies(); # For safety