#!/bin/sh
# This test is pretty silly. It checks that the constants look like what we
# expect them to. It does provide a simple example of how "prove" works though.
source wmap

if [ "${NAMESPACE}" != "wmap@wmap.dev" ]; then
	echo "NAMESPACE does not match the WMAP specification" >&2
	exit 1
fi

if ! echo "${VERSION}" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' > /dev/null 2>&1; then
	echo "VERSION does not match the WMAP specification" >&2
	exit 1
fi
