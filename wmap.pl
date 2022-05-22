#!/usr/bin/perl
use strict;
use warnings;


########################################################################
package main;

main() unless caller();

sub main {
}


########################################################################
package Subcommand;

sub new {
    my $class = shift;
    my $program = shift;

    my $self = {'program' => $program};

    return bless $self, $class;
}

sub silent {
    my $self = shift;

    die "Can't fork new Subcommand" unless
        defined(my $pid = open(CHILD, "-|"));

    if ($pid) {
        # parent
        while (<CHILD>) {
            # ignore
        }
        close(CHILD);
        return $?;
    } else {
        exec($self->{'program'}, @_) or
            die "Can't exec $self->{'program'}: $!";
    }
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
    return $?;
}

sub verify {
    my $self = shift;
    my $message_path = shift;
    my $principal = shift;
    my $namespace = shift;
    my $allowed_signers_path = shift;

    my $signature_path = "$message_path.sig";

    `ssh-keygen -Y verify -f $allowed_signers_path -I $principal -n $namespace -s $signature_path < $message_path`;
    return $?;
}


########################################################################
package WMAP;

sub version {
    return "0.1.0";
}

sub namespace {
    return 'wmap@wmap.dev';
}
