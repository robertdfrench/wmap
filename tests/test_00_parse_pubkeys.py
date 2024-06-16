from . import wmap

def test_parse_algorithm():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    assert(key.algorithm == wmap.Algorithm.RSA)

def test_parse_material():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    assert(key.material == "abc123")

def test_parse_comment():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    assert(key.comment == "blah blah blah")

def test_into_allowed_signer():
    key = wmap.AuthorizedKey.parse("ssh-rsa abc123 blah blah blah")
    profile = wmap.Profile("example")
    signer = key.into_allowed_signer(profile)
    assert(signer == "example namespaces=\"wmap@wmap.dev\" ssh-rsa abc123")
