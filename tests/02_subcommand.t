#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 1;

require WMAP;

my $rev = Subcommand->new("rev");
my $status = $rev->transform("tests/hello");
ok($status == 0, "Input can be transformed");
