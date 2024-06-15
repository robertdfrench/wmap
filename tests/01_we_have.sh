#!/bin/sh
# This test checks that the `we_have` function can correctly detect tools
# installed vs tools not installed.
source wmap

if ! we_have sh; then
	echo "Could not detect 'sh', which we are currently using" >&2
	exit 1
fi

if we_have tool-which-probably-does-not-exist; then
	echo "Detected a tool which probably does not exist" >&2
	exit 1
fi
