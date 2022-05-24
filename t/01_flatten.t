#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 1;

require "./wmap.pl";

my $sloppy_json = "{\n\t\"b\":     2,\n\"a\":1\n\t}";
my $flattened_json = JunkDrawer::flatten_json($sloppy_json);
ok("{\"a\":1,\"b\":2}" eq $flattened_json, "JSON can be flattened");
