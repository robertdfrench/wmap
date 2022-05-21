#!/usr/bin/perl
use strict;
use warnings;


########################################################################
package main;

main() unless caller();

sub main {
}


########################################################################
package SSH::Keygen;

sub new {
    my $class = shift;

    my $self = {};

    return bless $self, $class;
}

sub sign {
    my $self = shift;
    my $key_path = shift;
    my $namespace = shift;
    my $message_path = shift;

    `ssh-keygen -Y sign -f $key_path -n $namespace $message_path`;
}

########################################################################
package WMAP;

sub version {
    return "0.1.0";
}

sub namespace {
    return 'wmap@wmap.dev';
}
