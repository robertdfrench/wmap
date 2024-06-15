#!/usr/bin/perl
# This test package ensures that we can do basic ssh key operations,
# such as generating keys, signing messages with private keys, and
# verifying messages against public keys.
use strict;
use warnings;
use Test::Simple tests => 2;
require "./wmap";


# Setup
if (-e "tests/run/message.sig") {
    unlink("tests/run/message.sig");
}
unless (-e "tests/run/message") {
    `echo "Hello, World" > tests/run/message`
}
my $keygen = SSH::Keygen->new();


# Test 1: Signing messages should produce a signature file
$keygen->sign(
    "tests/run/id_rsa",
    "namespace",
    "tests/run/message"
);
ok(-f "tests/run/message.sig", "Messages can be signed");


# Test 2: The signature file and the message can be verified
my $status = $keygen->verify(
    "example/message.json",
    "https://github.com/robertdfrench",
    'wmap@wmap.dev',
    "tests/allowed_signers"
);
ok($status == 0, "Messages can be verified");
