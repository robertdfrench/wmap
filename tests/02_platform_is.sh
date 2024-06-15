#!/bin/sh
# This test is sortof bogus. It checks that the platform is the current
# platform, which basically just means its checking that uname is in the path.
# We provide it here only for completeness sake. It adds no value and only
# wastes CPU.
source wmap

platform=`uname`

if ! platform_is "${platform}"; then
	echo "Platform check failed. Something very silly is happening." >&2
	exit 1
fi
