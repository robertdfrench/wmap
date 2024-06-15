#!/usr/bin/perl
# This test package ensures that we can fetch something from the web.
use strict;
use warnings;
use Test::Simple tests => 1;
require "./wmap";

# Setup
my $http_client = HttpClient->new();
if (-e "tests/run/index.html") {
    unlink("tests/run/index.html");
}

# Test 1: Download the example.org web page
$http_client->download(
    "https://example.org/index.html",
    "tests/run/index.html"
);
ok(-f "tests/run/index.html", "Web page was downloaded");
