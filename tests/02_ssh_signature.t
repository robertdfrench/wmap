#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 2;

require "./wmap";

# Cleanup
if (-e "tests/run/message.sig") {
    unlink("tests/run/message.sig");
}
unless (-e "tests/run/message") {
    `echo "Hello, World" > tests/run/message`
}


# Tests
my $keygen = SSH::Keygen->new();
$keygen->sign(
    "tests/run/id_rsa",
    "namespace",
    "tests/run/message"
);
ok(-f "tests/run/message.sig", "Messages can be signed");

my $status = $keygen->verify(
    "example/message.json",
    "https://github.com/robertdfrench",
    'wmap@wmap.dev',
    "tests/allowed_signers"
);
ok($status == 0, "Messages can be verified");
