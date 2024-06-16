import os
import pytest
import subprocess
import tempfile
from pathlib import Path

from . import wmap

@pytest.fixture
def ssh_private_key_path():
    # Create a temporary directory to store the key pair
    with tempfile.TemporaryDirectory() as temp_dir:
        private_key_path = os.path.join(temp_dir, "id_ed25519")
        public_key_path = private_key_path + ".pub"
        
        # Generate the ed25519 SSH key pair using ssh-keygen
        subprocess.run([
            'ssh-keygen', '-t', 'ed25519', '-f', private_key_path, '-N', ''
        ], check=True)

        # Yield the private key path for use in tests
        yield private_key_path
        
        # Clean up the key files
        os.remove(private_key_path)
        os.remove(public_key_path)

def test_signing(ssh_private_key_path):
    profile = wmap.Profile("https://github.com/robertdfrench")
    private_key = wmap.PrivateKey(profile, ssh_private_key_path)
    with tempfile.NamedTemporaryFile() as f:
        f.write(b"Hello World!")
        private_key.sign(f.name)
        signature_file = Path(f.name + ".sig")
        assert signature_file.exists()
