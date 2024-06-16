import tempfile
import os

from . import wmap

def test_load_signature():
    with tempfile.NamedTemporaryFile(delete=False) as f:
        f.write(b"Hello World!")
    sig = wmap.Signature.load(f.name)
    assert sig.content == "SGVsbG8gV29ybGQh"
    os.remove(f.name)

def test_dump_signature():
    with tempfile.NamedTemporaryFile(delete=False) as f:
        f.write(b"Hello World!")
    sig = wmap.Signature.load(f.name)
    os.remove(f.name)

    with tempfile.NamedTemporaryFile(delete=False) as f:
        sig.dump(f.name)
    with open(f.name) as message:
        assert message.read() == "Hello World!"
    os.remove(f.name)
