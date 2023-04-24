#!/usr/bin/perl

use strict;

# https://metacpan.org/pod/Crypt::JWT
# https://packages.ubuntu.com/jammy/libcrypt-jwt-perl
use Crypt::JWT qw(encode_jwt);

use LWP::UserAgent;
use HTTP::Request::Common;
use JSON::XS;

my $app_id = "";
my $app_private_key = <<'EOF';
-----BEGIN RSA PRIVATE KEY-----
[...]
-----END RSA PRIVATE KEY-----
EOF

my $payload = {
	iss => "$app_id",
	sub => "hello"
};
my $jws_token = encode_jwt(
	auto_iat     => '1',
	relative_exp => '600',
	payload      => $payload,
	alg          => 'RS256',
	key          => \$app_private_key
);

print "$jws_token\n";

my $ua = LWP::UserAgent->new;
$ua->agent("cyclenerd-github-app");

# Login
my $request = GET "https://api.github.com/app/installations";
$request->header(
	'Accept'               => 'application/vnd.github+json',
	'Authorization'        => "Bearer $jws_token",
	'X-GitHub-Api-Version' => '2022-11-28'
);
my $response = $ua->request($request);
print "nStatus: '". $response->status_line ."'\nContent: '" . $response->decoded_content ."'\n";

# Get OAuth token
# /app/installations/INSTALLATION_ID/access_tokens
my $token_request = POST "https://api.github.com/app/installations/[INSTALLATION_ID]/access_tokens";
$token_request->header(
	'Accept'               => 'application/vnd.github+json',
	'Authorization'        => "Bearer $jws_token",
	'X-GitHub-Api-Version' => '2022-11-28'
);
my $token_response = $ua->request($token_request);
my $token = '';
if ($token_response->is_success) {
	my $json = decode_json($token_response->decoded_content);
	$token = $json->{'token'};
	print "$token";
} else {
	die "ERROR: !\nStatus: '". $token_response->status_line ."'\nContent: '" . $token_response->decoded_content ."'\n";
}

# https://docs.github.com/en/rest/orgs/members?apiVersion=2022-11-28#list-organization-members
#
# curl -L \
#   -H "Accept: application/vnd.github+json" \
#   -H "Authorization: Bearer <YOUR-TOKEN>"\
#   -H "X-GitHub-Api-Version: 2022-11-28" \
#   https://api.github.com/orgs/ORG/members

my $members_request = GET "https://api.github.com/orgs/NKN-IT/members";
$members_request->header(
	'Accept'               => 'application/vnd.github+json',
	'Authorization'        => "Bearer $token",
	'X-GitHub-Api-Version' => '2022-11-28'
);
my $members_response = $ua->request($members_request);
print "Status: '". $members_response->status_line ."'\nContent: '" . $members_response->decoded_content ."'\n";