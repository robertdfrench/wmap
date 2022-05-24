#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 1;

require "./wmap.pl";

my $pubkey = 'ssh-rsa ABC123 user@host';
my $signer = AllowedSigners::convert("principal", "namespace", $pubkey);

ok(
    $signer eq 'principal namespaces="namespace" ssh-rsa ABC123',
    "Pubkey converted to Allowed Signers format"
);
