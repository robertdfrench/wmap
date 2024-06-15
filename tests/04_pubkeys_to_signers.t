#!/usr/bin/perl
# This test package shows that we can construct a properly formatted
# AllowedSigners string, as described in the ALLOWED SIGNERS section of
# the SSH-KEYGEN(1) manual.
use strict;
use warnings;
use Test::Simple tests => 1;
require "./wmap";

# Test 1: Construct an Allowed Signers record based on principal,
# namespace, and pubkey.
my $pubkey = 'ssh-rsa ABC123 user@host';
my $signer = AllowedSigners::convert("principal", "namespace", $pubkey);

ok(
    $signer eq 'principal namespaces="namespace" ssh-rsa ABC123',
    "Pubkey converted to Allowed Signers format"
);
