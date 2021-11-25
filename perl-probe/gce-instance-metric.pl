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
# Add data point to Google monitoring time series metric
# Help: https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.timeSeries/create
#
# Filter for metrics explorer:
#   resource.type="gce_instance" AND metric.type = "[METRIC]"
# Example:
#   resource.type="gce_instance" AND metric.type = "custom.googleapis.com/vpc-probe/ping"

BEGIN {
	$VERSION = "1.0.0";
}

use utf8;
use strict;
use DateTime;
use DateTime::Format::RFC3339;
use LWP::UserAgent;
use HTTP::Request::Common;
use JSON::XS;


###############################################################################
# Options
###############################################################################

use App::Options (
	option => {
		# Help: https://cloud.google.com/sdk/gcloud/reference/auth/print-access-token
		# CLI: gcloud -q auth print-access-token
		token => {
			required    => 0,
			secure      => 1,
			type        => 'string',
			description => "Google Cloud access token [DEFAULT: Access token from metadata server]",
		},
		# Help: https://cloud.google.com/monitoring/api/ref_v3/rest/v3/TimeSeries#Metric
		#       https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors#MetricDescriptor
		metric => {
			required    => 1,
			default     => "vpc-probe/ping",
			type        => '/^[a-z0-9\-\/]{1,255}$/',
			description => "Metric type (name)",
		},
		value => {
			required    => 1,
			default     => "100",
			type        => 'int',
			description => "Value",
		},
		# GCE instance
		# Help: https://cloud.google.com/monitoring/api/resources#tag_gce_instance
		#       https://cloud.google.com/compute/docs/reference/rest/v1/instances
		instance => {
			required    => 1,
			type        => '/^[a-z0-9\-]{1,63}$/',
			description => "Google Compute Engine instance id",
		},
		zone => {
			required    => 1,
			type        => '/^[a-z0-9\-]{1,128}$/',
			description => "Google Compute Engine zone (the zone from the GCE instance)",
		},
		# Help: https://cloud.google.com/resource-manager/docs/creating-managing-projects
		project => {
			required    => 1,
			type        => '/^[a-z0-9\-]{6,60}$/',
			description => "Google Cloud project id (the project on which to execute the request)",
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
my $token       = $App::options{token};
my $metric      = $App::options{metric};
my $value       = $App::options{value};
my $instance    = $App::options{instance};
my $zone        = $App::options{zone};
my $project     = $App::options{project};
my $debug       = $App::options{debug_options};


###############################################################################
# JSON for monitoring API
###############################################################################

# The end of the time interval (RFC3339 UTC)
# Help: https://cloud.google.com/monitoring/api/ref_v3/rest/v3/TimeInterval
#       https://developers.google.com/protocol-buffers/docs/reference/google.protobuf#google.protobuf.Timestamp
my $dt = DateTime->now;
my $f  = DateTime::Format::RFC3339->new();
my $end_time = $f->format_datetime($dt);

# Create JSON for content body
# Help: https://cloud.google.com/monitoring/api/ref_v3/rest/v3/TimeSeries
$metric = "custom.googleapis.com/$metric";
my $json_text = qq ~
{ "timeSeries": [{
  "metric": { "type": "$metric" },
  "resource": {
    "type": "gce_instance",
    "labels": {
      "instance_id" : "$instance",
      "project_id"  : "$project",
      "zone"        : "$zone"
    }
  },
  "metricKind" : "GAUGE",
  "valueType"  : "INT64",
  "unit"       : "1",
  "points": [
    {
      "interval": { "endTime"    : "$end_time" },
      "value":    { "int64Value" : "$value" }
    }
  ]
}] }
~;
# Output JSON for debugging
print "JSON:\n$json_text\n" if $debug;


###############################################################################
# Access token
###############################################################################

# HTTP request
my $ua = LWP::UserAgent->new;
# Set timeout to 15sec
$ua->timeout("15");
# Get access token from metadata server if token is unset
unless ($token) {
	# Help: https://cloud.google.com/compute/docs/metadata/querying-metadata#endpoints
	my $metadata_api_url = "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token";
	print "Metadata API URL: $metadata_api_url\n" if $debug;
	my $metadata_request = GET "$metadata_api_url";
	$metadata_request->header( 'Metadata-Flavor' => 'Google' );
	my $metadata_response = $ua->request($metadata_request);
	my $metadata_http_status  = $metadata_response->status_line     || "";
	my $metadata_http_content = $metadata_response->decoded_content || "";
	# Output status and content for debugging
	if ($debug) {
		print "Metadata status: $metadata_http_status\n";
		print "Metadata content:\n$metadata_http_content\n";
	}
	# Read JSON and access_token
	if ($metadata_response->is_success) {
		my $metadata_json = eval { decode_json($metadata_http_content) };
		$token = $metadata_json->{'access_token'} || "";
		print "Token: $token\n" if $debug;
	}
}
# Check token again
unless ($token) {
	die "ERROR: Token missing!\n";
}


###############################################################################
# Metric
###############################################################################

# POST request to the given monitoring API URL
my $monitoring_api_url = "https://monitoring.googleapis.com/v3/projects/$project/timeSeries";
print "Google Monitoring API URL: $monitoring_api_url\n" if $debug;
my $request = POST "$monitoring_api_url";
$request->header(
	'Authorization'       => "Bearer $token",
	'X-Goog-User-Project' => "$project",
	'Content-Type'        => 'application/json',
	'Content-Length'      => length($json_text)
);
$request->content( $json_text );
my $response = $ua->request($request);
my $http_status  = $response->status_line     || "";
my $http_content = $response->decoded_content || "";

# Output status and content for debugging
if ($debug) {
	print "Status: $http_status\n";
	print "Content:\n$http_content\n";
}

# OK?
unless ($response->is_success) {
	my $error_message = "";
	# Read error message from Google
	if ($response && $response->decoded_content) {
		my $error_responce = eval { decode_json($http_content) };
		$error_message = $error_responce->{'error'}->{'message'} || "";
	}
	my $labels = "instance_id=$instance, project_id=$project, zone=$zone, metric=$metric, interval=$end_time, value=$value";
	die "ERROR: Data could not be saved for [ $labels ]\nStatus: $http_status\nMessage: $error_message\n";
}