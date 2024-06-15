#!/usr/bin/perl
# This test package ensures that we can do basic ssh key operations,
# such as generating keys, signing messages with private keys, and
# verifying messages against public keys.
use strict;
use warnings;
use Test::Simple tests => 2;
require "./wmap";


# Setup
`mkdir tests/run`;
`echo "Hello, World" > tests/run/message`;
`ssh-keygen -f tests/run/id_rsa -N ''`;

open(my $pubkey, '<', "tests/run/id_rsa.pub");
my $key_material = <$pubkey>;
close($pubkey);

my $allowed_signer = "username namespaces=\"namespace\" " . $key_material;
open(my $allowed_signers, '>', 'tests/run/allowed_signers');
print $allowed_signers $allowed_signer;
close($allowed_signers);

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
    "tests/run/message",
    "username",
    'namespace',
    "tests/run/allowed_signers"
);
ok($status == 0, "Messages can be verified");
