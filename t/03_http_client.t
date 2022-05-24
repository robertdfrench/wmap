#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 1;

require "./wmap.pl";

my $http_client = HttpClient->new();
if (-e "t/run/index.html") {
    unlink("t/run/index.html");
}
$http_client->download(
    "https://example.org/index.html",
    "t/run/index.html"
);

ok(-f "t/run/index.html", "Web page was downloaded");
