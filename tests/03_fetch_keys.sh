#!/bin/sh
# This test checks that we can fetch the ssh public keys associated with a given
# WMAP profile.
source wmap

if ! fetch_keys "https://github.com/robertdfrench" | grep ssh > /dev/null 2>&1; then
	echo "pubkeys did not contain 'ssh' and are probably not valid" >&2
	exit 1
fi
