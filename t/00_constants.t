#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 2;

require "./wmap.pl";

my $version = WMAP::version();
ok($version =~ /\d+.\d+.\d+/, "Version is numeric");

my $namespace = WMAP::namespace();
ok($namespace eq 'wmap@wmap.dev', "Using the designated namespace");
