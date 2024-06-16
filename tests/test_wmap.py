import os
from pathlib import Path
import pytest
import subprocess
import tempfile
from . import wmap


@pytest.fixture
def ssh_private_key_path():
    # Create a temporary directory to store the key pair
    with tempfile.TemporaryDirectory() as temp_dir:
        private_key_path = os.path.join(temp_dir, "id_ed25519")

        # Generate the ed25519 SSH key pair using ssh-keygen
        subprocess.run([
            'ssh-keygen', '-t', 'ed25519', '-f', private_key_path, '-N', ''
        ], check=True)

        # Yield the private key path for use in tests
        yield private_key_path


def test_algorithm_rsa():
    rsa = wmap.Algorithm.parse("ssh-rsa")
    assert rsa == wmap.Algorithm.RSA


def test_algorithm_ed25519():
    ed25519 = wmap.Algorithm.parse("ssh-ed25519")
    assert ed25519 == wmap.Algorithm.ED25519


def test_algorithm_bogus():
    with pytest.raises(Exception):
        wmap.Algorithm.parse("ssh-junk")


def test_authorized_key_parse_algorithm():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    assert key.algorithm == wmap.Algorithm.RSA


def test_authorized_key_parse_material():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    assert key.material == "abc123"


def test_authorized_key_parse_comment():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    assert key.comment == "blah blah blah"


def test_authorized_key_into_allowed_signer():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    profile = wmap.Profile("example")
    signer = key.into_allowed_signer(profile)
    assert signer == "example namespaces=\"wmap@wmap.dev\" ssh-rsa abc123"


def test_profile_key_url():
    profile_url = "https://github.com/robertdfrench"
    authorized_keys_url = "https://github.com/robertdfrench.keys"
    profile = wmap.Profile(profile_url)
    assert profile.authorized_keys_url() == authorized_keys_url


def test_profile_fetch_authorized_keys_text():
    profile = wmap.Profile("https://github.com/robertdfrench")
    authorized_keys = profile.authorized_keys()
    assert len(authorized_keys) > 0


def test_profile_allowed_signers():
    profile = wmap.Profile("https://github.com/robertdfrench")
    for signer in profile.allowed_signers():
        assert signer.startswith("https://github.com/robertdfrench")


def test_private_key_signing(ssh_private_key_path):
    profile = wmap.Profile("https://github.com/robertdfrench")
    private_key = wmap.PrivateKey(profile, ssh_private_key_path)
    with tempfile.NamedTemporaryFile() as f:
        f.write(b"Hello World!")
        f.flush()
        private_key.sign(f.name)
        signature_file = Path(f.name + ".sig")
        assert signature_file.exists()


def test_signature_load():
    with tempfile.NamedTemporaryFile() as f:
        f.write(b"Hello World!")
        f.flush()
        sig = wmap.Signature.load(f.name)
        assert sig.content == "SGVsbG8gV29ybGQh"


def test_signature_dump():
    with tempfile.NamedTemporaryFile() as f:
        f.write(b"Hello World!")
        f.flush()
        sig = wmap.Signature.load(f.name)

    with tempfile.NamedTemporaryFile() as f:
        sig.dump(f.name)
        with open(f.name) as message:
            assert message.read() == "Hello World!"


def test_profile_verify_signed_file():
    profile = wmap.Profile("https://github.com/robertdfrench")
    with open("tests/message.txt", 'rb') as f:
        assert profile.verify_signed_data(f.read(), "tests/message.txt.sig")
