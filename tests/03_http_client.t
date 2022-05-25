#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 1;

require "./wmap";

my $http_client = HttpClient->new();
if (-e "tests/run/index.html") {
    unlink("tests/run/index.html");
}
$http_client->download(
    "https://example.org/index.html",
    "tests/run/index.html"
);

ok(-f "tests/run/index.html", "Web page was downloaded");
