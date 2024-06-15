#!/usr/bin/perl
# This test package is pretty silly. It checks that the constants look
# like what we expect them to. It does provide a simple example of how
# Perl's Test::Simple module works though.
use strict;
use warnings;

use Test::Simple tests => 2;

require "./wmap";

# Test 1: Assert that the Version string is numeric.
my $version = WMAP::version();
ok($version =~ /\d+.\d+.\d+/, "Version is numeric");

# Test 2: Assert that the ssh namespace is wmap@wmap.dev.
my $namespace = WMAP::namespace();
ok($namespace eq 'wmap@wmap.dev', "Using the designated namespace");
