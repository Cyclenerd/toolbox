#!/usr/bin/perl 


#
# This small Perl script converts the Quäldich.de (http://www.quaeldich.de/) location JSON into a GeoJSON file.
#
# Example with the island of Mallorca:
#
# http://www.quaeldich.de/paesse/puig-major/karte/
#
# curl -s -f 'http://www.quaeldich.de/webinclude/php/location_json_v3.php?swlon=1.3197287499999675&swlat=39.153399417839836&nelon=4.4508322656249675&nelat=40.41967792946016&items=0' | perl quaeldich2geojson.pl > mallorca.geojson
#
#
# Output:
# https://github.com/Cyclenerd/cyclenerd.github.io/blob/master/mallorca/paesse.geojson
#


use strict;
use JSON;

my $input = '';
while (<STDIN>) {
	$input .= $_;
}

my $json = decode_json $input;

my @paesse = ();
foreach my $pass (@{$json->{'paesse'}}) {
	my $name   = $pass->{'name'};
	my $textid = $pass->{'textid'};
	my $lat    = $pass->{'latitude'};
	my $lng    = $pass->{'longitude'};
	my $alt    = $pass->{'output'};
	$alt =~ s/&nbsp;m//;	
	my $point = {
		'type' => 'Feature',
		'geometry' => {
			'type' => 'Point',
			'coordinates' => [$lng, $lat]
		},
		'properties' => {
			'name' => $name,
			'type' => 'Mountain',
			'meters' => $alt,
			'marker-symbol' => 'triangle',
			'url' => "http://www.quaeldich.de/paesse/$textid"
		}
	};
	push(@paesse, $point);
}

my $output = {
	'type' => 'FeatureCollection',
	'features' => \@paesse
};

print to_json($output, { ascii => 1, pretty => 1 } );
