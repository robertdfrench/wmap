#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 1;

require WMAP;

my $keygen = SSH::Keygen->new();
if (-e "tests/run/message.sig") {
    unlink("tests/run/message.sig");
}
$keygen->sign("tests/run/id_rsa","namespace","tests/run/message");
ok(-f "tests/run/message.sig", "Messages can be signed");
