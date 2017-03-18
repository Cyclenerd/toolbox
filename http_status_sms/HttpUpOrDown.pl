#!/usr/bin/perl

# Copyright (C) 2009 Nils Knieling <http://trainingstagebuch.org/>
#
# ***********************************************************************
#
# HTTP-Status ueberwachen
# bei Statusaenderung UP (200) -> DOWN (!200) & DOWN -> UP SMS versenden
#
# ***********************************************************************
#
# Die Veroeffentlichung dieses Programms erfolgt in der Hoffnung,
# dass es dir von Nutzen sein wird, aber OHNE IRGENDEINE GARANTIE!
#
# Dieses Script ist freie Software.
# Du kannst es gerne weitergeben und/oder modifizieren.
#
# ***********************************************************************
#
# Tipps
#
# CPAN Module installieren:
# root> perl -MCPAN -e shell
#   install HTTP::Lite
#   install Frontier::Client
#
# Frontier::Client braucht XML::Parser und Crypt::SSLeay.
# Bei der Installation kann es zu Fehlern kommen. Fuer Debian gibt es z.B.
# Packete die sich einfach und problemlos installieren lassen:
# root> apt-get install libxml-parser-perl
# root> apt-get install libcrypt-ssleay-perl
#
# Crontab, alle 30 Minuten HTTP-Status pruefen:
# */30 * * * * perl /home/nils/HttpUpOrDown.pl

use HTTP::Lite;
use Frontier::Client; # fuer XMLRPC
use strict;

# *************************** KONFIGURATION ******************************

# Zu ueberwachende Services hier eintragen
my %urls = (
	# Servicename => URL
	trainingstagebuch => 'http://trainingstagebuch.org/',
	# weitere ...
);
# sipgate.de Daten
my %sipgate = ();
$sipgate{"user"} 	= ''; # Benutzername der Web-Zugangsdaten (nicht SIP)
$sipgate{"pass"} 	= ''; # Kennwort (nur Buchstaben und Zahlen)
$sipgate{"tel"} 	= ''; # An welche Telefonnummer soll die SMS gehen? (49157...)

# *************************** KONFIGURATION ENDE **************************

sub statusMerken($$) {
	my ($url, $status) = @_;
	open STATUS, ">$url.log" or die "Status-Datei, $url kann nicht geschieben werden!";
	print STATUS "$status";
	close STATUS;
}

sub statusLesen($) {
	my ($url) = @_;
	# Beim ersten Durchlauf kann die Warnung ignoriert werden
	open STATUS, "<$url.log" or warn "Status-Datei, $url kann nicht gelesen werden!";
	my $status = <STATUS>;
	close STATUS;
	return $status;
}

sub meldungMachen($$$$) {
	my ($user, $pass, $tel, $msg) = @_;
	if ($user && $pass && $tel && $msg) {
		my $url = "https://$user:$pass\@api.sipgate.net/RPC2";
		my $xmlrpc_client = Frontier::Client->new( 'url' => $url );
		my $args_identify = { ClientName => 'HttpUpOrDown', ClientVersion => '1.0', ClientVendor => 'Trainingstagebuch.org' };
		my $xmlrpc_identify = $xmlrpc_client->call( "samurai.ClientIdentify", $args_identify );
		if ($xmlrpc_identify->{'StatusCode'} == 200) {
			my $args = { RemoteUri => "sip:$tel\@sipgate.net", TOS => "text", Content => "$msg" };
			my $xmlrpc_result = $xmlrpc_client->call( "samurai.SessionInitiate", $args );
			unless ($xmlrpc_result->{'StatusCode'} == 200) {
				warn "SMS an $tel konnte nicht versand werden!";
			}
	} else {
		warn "Anmeldung bei sipgate wurde verweigert!\n";
	}
	} else {
		warn "Angaben fuer SMS fehlen!"
	}
}


foreach my $url (keys(%urls)) {
	if ($urls{$url} =~ /^(http.*)$/) {
		my $http = new HTTP::Lite;
		my $req = $http->request("$urls{$url}");
		if ($req eq "200" || $req eq "302") {
			# Wenn keine Statusaenderung auch keine Meldung!
			my $up = "$url UP $req " . $http->status_message();
			meldungMachen($sipgate{"user"}, $sipgate{"pass"}, $sipgate{"tel"}, $up) if (statusLesen($url) =~ /DOWN/);
			#print $http->body();
			statusMerken($url, 'UP');
		} else {
			my $down = "$url DOWN $req " . $http->status_message();
			meldungMachen($sipgate{"user"}, $sipgate{"pass"}, $sipgate{"tel"}, $down) if (statusLesen($url) =~ /UP/);
			statusMerken($url, 'DOWN');
		}
	}
}