#!/bin/sh
# This test checks that we can construct a valid ALLOWED SIGNERS file for
# "profile". The ALLOWED SIGNERS format is described in the ALLOWED SIGNERS (all
# caps, very shouty) section of the ssh-keygen(1) manual entry.
source wmap

profile="https://github.com/robertdfrench"

if ! allowed_signers "$profile" | grep ssh > /dev/null 2>&1; then
	echo "allowed signers file does not contain the correct pubkey signature" >&2
	exit 1
fi

if ! allowed_signers "$profile" | grep "wmap@wmap.dev" > /dev/null 2>&1; then
	echo "allowed signers file does not contain the correct namespace" >&2
	exit 1
fi

if ! allowed_signers "$profile" | grep "$profile" > /dev/null 2>&1; then
	echo "allowed signers file does not contain the correct namespace" >&2
	exit 1
fi

num_keys=`fetch_keys "$profile" |  wc -l`
num_signers=`allowed_signers "$profile" | wc -l`
if [ $num_keys -ne $num_signers ]; then
	echo "Different number of keys than signers" >&2
	exit 1
fi
