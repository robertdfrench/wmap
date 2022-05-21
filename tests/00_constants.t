#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 1;

require WMAP;

my $version = WMAP::version();
ok($version =~ /\d+.\d+.\d+/, "Version is numeric");
