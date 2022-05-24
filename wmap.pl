#!/usr/bin/perl
use strict;
use warnings;


########################################################################
package main;

main() unless caller();

sub main {
    print "Hello, World!";
}


########################################################################
package HttpClient;

sub new {
    my $class = shift;

    my $self = { };

    return bless $self, $class;
}

sub download {
    my $self = shift;
    my $remote_url = shift;
    my $local_path = shift;

    my $curl = Subcommand->new("curl");

    return $curl->invoke(
        "-s",$remote_url,
        "-o",$local_path
    );
}

########################################################################
package JunkDrawer;
use JSON::PP;

sub flatten_json {
    my $json_source = shift;

    my $jq = JSON::PP->new->utf8->canonical;

    my $json_object = $jq->decode($json_source);
    my $normalized_source = $jq->encode($json_object);
    return $normalized_source;
}


########################################################################
package Subcommand;

sub new {
    my $class = shift;
    my $program = shift;

    my $self = {'program' => $program};

    return bless $self, $class;
}

sub invoke {
    my $self = shift;

    my $spell = "$self->{'program'}";

    die "Can't fork new Subcommand" unless
        defined(my $pid = open(CHILD, "-|", $spell, @_));

    if ($pid) {
        while (<CHILD>) {
        }
        close(CHILD);
        return $?;
    } else {
        exec($self->{'program'}, @_) or
            die "Can't exec $self->{'program'}: $!";
    }
}

sub transform {
    my $self = shift;
    my $input = shift;

    my $pid = open(CHILD, "|-", "$self->{'program'}", @_);

    die "Can't fork new Subcommand" unless defined($pid);

    if ($pid) {
        print CHILD $input;
        close(CHILD);
        return $?;
    } else {
        exec($self->{'program'}, @_) or
            die "Can't execute $self->{'program'}: $!";
    }
}


########################################################################
package SSH::Keygen;

sub new {
    my $class = shift;

    my $subcommand = Subcommand->new('ssh-keygen');
    my $self = {
        'subcommand' => $subcommand
    };

    return bless $self, $class;
}

sub sign {
    my $self = shift;
    my $key_path = shift;
    my $namespace = shift;
    my $message_path = shift;

    return $self->{'subcommand'}->invoke(
        "-Y", "sign",
        "-f", $key_path,
        "-n", $namespace,
        $message_path
    );
}

sub verify {
    my $self = shift;
    my $message_path = shift;
    my $principal = shift;
    my $namespace = shift;
    my $allowed_signers_path = shift;

    my $signature_path = "$message_path.sig";
    my $message;
    {
        open(my $fh, '<', $message_path) or
            die "Can't open '$message_path': $!";

        local $/ = undef;
        $message = <$fh>;
        close($fh);
    }

    return $self->{'subcommand'}->transform(
        $message,
        "-Y", "verify",
        "-f", $allowed_signers_path,
        "-I", $principal,
        "-n", $namespace,
        "-s", $signature_path
    );
}


########################################################################
package WMAP;

sub version {
    return "0.1.0";
}

sub namespace {
    return 'wmap@wmap.dev';
}
