# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright 2024 Robert D. French
import os
from pathlib import Path
import pytest
import subprocess
import tempfile
import json
from . import wmap


@pytest.fixture
def ssh_private_key_path():
    """
    Create a temporary ssh keypair which can be used for testing. This function
    yields the path to the private key, and destroys both the public and
    private keys once all tests have completed.
    """
    # Create a temporary directory to store the key pair
    with tempfile.TemporaryDirectory() as temp_dir:
        private_key_path = os.path.join(temp_dir, "id_ed25519")

        # Generate the ed25519 SSH key pair using ssh-keygen
        subprocess.run([
            'ssh-keygen', '-t', 'ed25519', '-f', private_key_path, '-N', ''
        ], check=True)

        # Yield the private key path for use in tests
        yield private_key_path


def test_algorithm_parse():
    """
    Ensure that we can parse ssh key algorithm strings into Algorithm enums.
    """
    rsa = wmap.Algorithm.parse("ssh-rsa")
    assert rsa == wmap.Algorithm.RSA
    ed25519 = wmap.Algorithm.parse("ssh-ed25519")
    assert ed25519 == wmap.Algorithm.ED25519
    with pytest.raises(Exception):
        wmap.Algorithm.parse("ssh-junk")


def test_authorized_key_parse_algorithm():
    """
    Ensure that we can parse an authorized key record into an AuthorizedKey
    object, with each field intact.
    """
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    assert key.algorithm == wmap.Algorithm.RSA
    assert key.material == "abc123"
    assert key.comment == "blah blah blah"


def test_authorized_key_into_allowed_signer():
    """
    Show that we can convert an authorized key record into an ALLOWED SIGNERS
    record (as described in ssh-keygen(1)).
    """
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    profile = wmap.Profile("example")
    signer = key.into_allowed_signer(profile)
    assert signer == "example namespaces=\"wmap@wmap.dev\" ssh-rsa abc123"


def test_profile_key_url():
    """
    Turn a github username into a URL for that user's SSH public keys.
    """
    username = "robertdfrench"
    authorized_keys_url = "https://github.com/robertdfrench.keys"
    profile = wmap.Profile(username)
    assert profile.authorized_keys_url() == authorized_keys_url


def test_profile_fetch_authorized_keys_text():
    """
    Show that a valid github username (in this case, my own) has more than zero
    keys.
    """
    profile = wmap.Profile("robertdfrench")
    authorized_keys = profile.authorized_keys()
    assert len(authorized_keys) > 0


def test_profile_allowed_signers():
    """
    Show that we can construct a list of ALLOWED SIGNERS for each key in a
    github user's profile. Without knowing the key material ahead of time, all
    we can do is spot check the format of the ALLOWED SIGNERS records.

    See ssh-keygen(1) for more information on this format.
    """
    profile = wmap.Profile("robertdfrench")
    for signer in profile.allowed_signers():
        assert signer.startswith("robertdfrench")
        assert "wmap@wmap.dev" in signer


def test_private_key_signing(ssh_private_key_path):
    """
    Show that we can sign a file (and produce an OpenSSH signatre) using the
    temporary private key.
    """
    profile = wmap.Profile("example")
    private_key = wmap.PrivateKey(profile, ssh_private_key_path)
    with tempfile.NamedTemporaryFile() as f:
        f.write(b"Hello World!")
        f.flush()
        private_key.sign(f.name)
        signature_file = Path(f.name + ".sig")
        assert signature_file.exists()


def test_signature_load():
    """
    Show that we can load a fake signature (really, just a text file) and
    compare it against its known base64 representation.
    """
    with tempfile.NamedTemporaryFile() as f:
        f.write(b"Hello World!")
        f.flush()
        sig = wmap.Signature.load(f.name)
        assert sig.content == "SGVsbG8gV29ybGQh"


def test_signature_dump():
    """
    Show that we can store a signature file to disk in its original format. In
    this case, we use a fake "signature" (the phrase Hello, World) for
    simplicity.
    """
    with tempfile.NamedTemporaryFile() as f:
        f.write(b"Hello World!")
        f.flush()
        sig = wmap.Signature.load(f.name)

    with tempfile.NamedTemporaryFile() as f:
        sig.dump(f.name)
        with open(f.name) as message:
            assert message.read() == "Hello World!"


def test_profile_verify_signed_file():
    """
    Using a file that was signed by me and checked into this repo, verify its
    signature against the SSH public keys on my github profile.
    """
    profile = wmap.Profile("robertdfrench")
    with open("tests/message.txt", 'rb') as f:
        assert profile.verify_signed_data(f.read(), "tests/message.txt.sig")


def test_message_load_from_files():
    """
    Show that we can construt a Message object from a file, a profile, and a
    signature.
    """
    profile = wmap.Profile("robertdfrench")
    message = wmap.Message.from_signed_file(profile, "tests/message.txt")
    assert message.profile == profile
    assert message.body == b'My name is Robert French, and I hope you think WMAP is as neat as I do!\n'  # noqa: E501
    assert message.signature == wmap.Signature.load("tests/message.txt.sig")


def test_message_into_dict():
    """
    Show that we can turn a Message object into a python dictionary (which
    would then be turned into JSON). The body and signature here are
    base64-encoded versions of the tests/messages.txt and
    tests/messages.txt.sig files, respectively.
    """
    profile = wmap.Profile("robertdfrench")
    message = wmap.Message.from_signed_file(profile, "tests/message.txt")
    d = message.into_dict()
    assert d['profile'] == "robertdfrench"
    assert d['body'] == "TXkgbmFtZSBpcyBSb2JlcnQgRnJlbmNoLCBhbmQgSSBob3BlIHlvdSB0aGluayBXTUFQIGlzIGFzIG5lYXQgYXMgSSBkbyEK"  # noqa: E501
    assert d['signature'] == "LS0tLS1CRUdJTiBTU0ggU0lHTkFUVVJFLS0tLS0KVTFOSVUwbEhBQUFBQVFBQUFSY0FBQUFIYzNOb0xYSnpZUUFBQUFNQkFBRUFBQUVCQU16eGUrdGo4Nk44TnhvajRXOUJWWApuSG56VzBScXlrcmtDZ2xvZFBNbjd5Y2ZMcWpTdGNBTE15STBsZ24zSmVIZHU4R0xiTlpYMkNlL0huN0hHMWVtNERUN096CnhaUXpwcTZ2SmR0MFMzVi8zK0w2TW1URC9JQURSNzRYblIyRWtZUGg0UXJ1QzhSMTVuZ0tKQ29xcC8vWEN1d3pBWmlzQjQKNG1OdXJWTWlGR01pQkpnWUpJUEFKcjk3OWdkdm1hM1hvWnFGaTUrdkc4TmhRMXlQTHZuRTZCaHdLQjdqU0xjQllIVDl2UwpJeDdKOCswRjNYZE9Xd0VScGZwQzhUeS8zVVhtUWVMa1RzQi9INWNGRFB4RHJLMjVqVWpvZDhleGtYajJERC9VYW44VWhrCjZDVGJEeFRmNlRKK3ZwSXhSM2VRVWVDU1BpS2prOTNzaVJCcUY0NzhFQUFBQU5kMjFoY0VCM2JXRndMbVJsZGdBQUFBQUEKQUFBR2MyaGhOVEV5QUFBQkZBQUFBQXh5YzJFdGMyaGhNaTAxTVRJQUFBRUFZUnhwYnc5N2pUcXNsNG5Da3MzYXpDKytjdQpJV2lOZk9Mc3lqdGFUcnJ0S0ZEOWd2YTRLdTNpVTVSWS9oVVZmaTl6WkxyamJrem00aDJaOTUwVjZJK2dWNmNEQk9wQXppClNNOFduTTJzelFBa3FPQlVlQVFVNEExd0VjOXpMREJnUnNyU1FIY1lldk1uNWI1anNnMlNPOTJoemZRK3BGS0RBbi8xaHAKbmhpa0d2SDZ2ckZiY2ZFQ3QxYUlwR0pRcVZ3dlZ2b0h4dVpoYlNjTjNFV0ZSdDBpUEE5dU1GeFp3T1dyMzladWlPRkFuawpXendRWUxsQ2RCQktUM01VWlVpWHBmWkQyQ2tEYlFxZEF6Y2w1bTByeFRkbDlWZG9BVGtwVjM2SEhldHNpbmx4TUl4cGk4CnBvaGtTV0hrN05RdlBtMWlHRUZTUS8zS1RUa281SENxWDU2UT09Ci0tLS0tRU5EIFNTSCBTSUdOQVRVUkUtLS0tLQo="  # noqa: E501


def test_message_dump():
    """
    Show that we once we write a Message object to disk, it can be loaded into
    memory as a dictionary (via json.load) whose fields should match the values
    below.  The body and signature here are base64-encoded versions of the
    tests/messages.txt and tests/messages.txt.sig files, respectively.
    """
    profile = wmap.Profile("robertdfrench")
    message = wmap.Message.from_signed_file(profile, "tests/message.txt")
    with tempfile.NamedTemporaryFile() as f:
        message.dump(f.name)
        with open(f.name) as message:
            d = json.load(message)
            assert d['profile'] == "robertdfrench"
            assert d['body'] == "TXkgbmFtZSBpcyBSb2JlcnQgRnJlbmNoLCBhbmQgSSBob3BlIHlvdSB0aGluayBXTUFQIGlzIGFzIG5lYXQgYXMgSSBkbyEK"  # noqa: E501
            assert d['signature'] == "LS0tLS1CRUdJTiBTU0ggU0lHTkFUVVJFLS0tLS0KVTFOSVUwbEhBQUFBQVFBQUFSY0FBQUFIYzNOb0xYSnpZUUFBQUFNQkFBRUFBQUVCQU16eGUrdGo4Nk44TnhvajRXOUJWWApuSG56VzBScXlrcmtDZ2xvZFBNbjd5Y2ZMcWpTdGNBTE15STBsZ24zSmVIZHU4R0xiTlpYMkNlL0huN0hHMWVtNERUN096CnhaUXpwcTZ2SmR0MFMzVi8zK0w2TW1URC9JQURSNzRYblIyRWtZUGg0UXJ1QzhSMTVuZ0tKQ29xcC8vWEN1d3pBWmlzQjQKNG1OdXJWTWlGR01pQkpnWUpJUEFKcjk3OWdkdm1hM1hvWnFGaTUrdkc4TmhRMXlQTHZuRTZCaHdLQjdqU0xjQllIVDl2UwpJeDdKOCswRjNYZE9Xd0VScGZwQzhUeS8zVVhtUWVMa1RzQi9INWNGRFB4RHJLMjVqVWpvZDhleGtYajJERC9VYW44VWhrCjZDVGJEeFRmNlRKK3ZwSXhSM2VRVWVDU1BpS2prOTNzaVJCcUY0NzhFQUFBQU5kMjFoY0VCM2JXRndMbVJsZGdBQUFBQUEKQUFBR2MyaGhOVEV5QUFBQkZBQUFBQXh5YzJFdGMyaGhNaTAxTVRJQUFBRUFZUnhwYnc5N2pUcXNsNG5Da3MzYXpDKytjdQpJV2lOZk9Mc3lqdGFUcnJ0S0ZEOWd2YTRLdTNpVTVSWS9oVVZmaTl6WkxyamJrem00aDJaOTUwVjZJK2dWNmNEQk9wQXppClNNOFduTTJzelFBa3FPQlVlQVFVNEExd0VjOXpMREJnUnNyU1FIY1lldk1uNWI1anNnMlNPOTJoemZRK3BGS0RBbi8xaHAKbmhpa0d2SDZ2ckZiY2ZFQ3QxYUlwR0pRcVZ3dlZ2b0h4dVpoYlNjTjNFV0ZSdDBpUEE5dU1GeFp3T1dyMzladWlPRkFuawpXendRWUxsQ2RCQktUM01VWlVpWHBmWkQyQ2tEYlFxZEF6Y2w1bTByeFRkbDlWZG9BVGtwVjM2SEhldHNpbmx4TUl4cGk4CnBvaGtTV0hrN05RdlBtMWlHRUZTUS8zS1RUa281SENxWDU2UT09Ci0tLS0tRU5EIFNTSCBTSUdOQVRVUkUtLS0tLQo="  # noqa: E501


def test_message_load():
    """
    Show that we can load a Message object from disk. We compare that object to
    its constituent parts.
    """
    profile = wmap.Profile("robertdfrench")
    signature = wmap.Signature.load("tests/message.txt.sig")
    message = wmap.Message.from_signed_file(profile, "tests/message.txt")
    with tempfile.NamedTemporaryFile() as f:
        message.dump(f.name)
        message = wmap.Message.load(f.name)
        assert message.profile == profile
        assert message.signature == signature
