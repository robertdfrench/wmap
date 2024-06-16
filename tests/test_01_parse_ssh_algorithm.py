import pytest
from . import wmap

def test_rsa():
    rsa = wmap.Algorithm.parse("ssh-rsa")
    assert(rsa == wmap.Algorithm.RSA)

def test_ed25519():
    ed25519 = wmap.Algorithm.parse("ssh-ed25519")
    assert(ed25519 == wmap.Algorithm.ED25519)

def test_bogus():
    with pytest.raises(Exception):
        wmap.Algorithm.parse("ssh-junk")
