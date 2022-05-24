#!/usr/bin/perl
use strict;
use warnings;

use Test::Simple tests => 2;
use File::Path qw(make_path);

require "./wmap";

# Cleanup
unless (-e "t/run") {
    make_path("t/run");
}
if (-e "t/run/message.sig") {
    unlink("t/run/message.sig");
}
unless (-e "t/run/message") {
    `echo "Hello, World" > t/run/message`
}
unless (-e "t/run/id_rsa") {
    `ssh-keygen -f t/run/id_rsa -N ''`
}

# Tests
my $keygen = SSH::Keygen->new();
$keygen->sign(
    "t/run/id_rsa",
    "namespace",
    "t/run/message"
);
ok(-f "t/run/message.sig", "Messages can be signed");

my $status = $keygen->verify(
    "example/message.json",
    "https://github.com/robertdfrench",
    'wmap@wmap.dev',
    "t/allowed_signers"
);
ok($status == 0, "Messages can be verified");
