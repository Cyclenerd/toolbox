#!/usr/bin/perl

print "-" x 60;
print <<FOO;

SAP listened!
There is now a better way to deploy HTML5 apps to SCP Neo.

Please use the Multi-Target Application (MTA) build tool:
    https://github.com/SAP/cloud-mta-build-tool

There is also an optimized Docker Image for GitLab:
    https://github.com/Cyclenerd/scp-tools-gitlab
FOO
print "-" x 60;
print "\n";
die "Update your pipeline now!\n";