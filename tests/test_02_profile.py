from . import wmap

def test_key_url():
    profile_url = "https://github.com/robertdfrench"
    authorized_keys_url = "https://github.com/robertdfrench.keys"
    profile = wmap.Profile(profile_url)
    assert(profile.authorized_keys_url() == authorized_keys_url)

def test_fetch_authorized_keys_text():
    profile = wmap.Profile("https://github.com/robertdfrench")
    authorized_keys = profile.authorized_keys()
    assert(len(authorized_keys) > 0)

def test_allowed_signers():
    profile = wmap.Profile("https://github.com/robertdfrench")
    for signer in profile.allowed_signers():
        assert(signer.startswith("https://github.com/robertdfrench"))
