# WMAP
*The Web-based Message Authentication Protocol*

WMAP lets you validate messages against your friends' SSH pubkeys.
GitHub, GitLab, and BitBucket all post SSH public keys in known
locations: simply sign your messages as `https://github.com/<USERNAME>`
and your friends will be able to verify their integrity.

This repository contains a specification and reference implementation
for a protocol which can be used for relatively secure internet
communication. Many such protocols already exist, the goal of this one
is to see what can be done with tools that software engineers are likely
to already have lying around: `git`, `ssh`, etc.

Particularly, WMAP aims to take advantage of the fact that git hosts
like GitHub, GitLab, etc tend to make users' SSH public keys available
in a [known location](https://github.com/robertdfrench.keys):
```mermaid
sequenceDiagram
    Alice->>GitHub: Upload SSH Pubkey
    Alice->>Alice: Sign Message for Bob
    Alice->>Bob: Send Message to Bob
    Bob->>GitHub: Fetch Alice's Pubkey
    Bob->>Bob: Verify Message Came from Alice
```

## Informal Specification
WMAP messages have the following structure:
```json
{
    "author": "https://github.com/robertdfrench",
    "message": "SGVsbG8sIHdvcmxkLgo=",
    "signature": "U1NIU0lHAA...jiam+SDCzaoFiSvw==",
}
```
where `author` is the URL of your profile on a WMAP-compatible website
`message` is a string that you would like to send, and `signature` is a
WMAP-specific SSH signature.


## Profile URL
A *profile URL* is an `https://` url which is valid, and for which a
corresponding *pubkey URL* exists:

* Profile URL: `https://example.org/alice`
* Pubkey URL: `https://example.org/alice.keys`

In WMAP, a *profile URL* is roughly equivalent to a username or an email
address: if I want to refer to someone, I do it by using their *profile
URL*.


### Pubkey URL
A *pubkey URL* is an `https://` url which is obtained by appending
the string ".keys" to a user's profile URL. This URL should support
`GET` queries, and should return a `text/plain` document containing a
list of SSH public keys in the [`authorized_keys` file
format](https://man.openbsd.org/sshd#AUTHORIZED_KEYS_FILE_FORMAT).


### `author` Field
We include the `author` field in the document so that the recipient can
infer where to get a list of authorized keys.


### `message` Field
This is a base64-encoded version of the data being sent.


### `signature` Field
This contains the SSH signature of the `message` field.

## Tutorial
Sure! Here’s a step-by-step tutorial on how to use `wmap` to sign and verify documents using your GitHub SSH keys.

### Prerequisites
1. You have a GitHub account.
2. You use SSH keys to authenticate to GitHub.
3. You have Python 3 installed on your machine.
4. You have `ssh-keygen` installed on your machine (usually included with OpenSSH, which is typically pre-installed on Linux and macOS).

### Installation

1. **Download the `wmap` script**:
   Save the script to your local machine. You can name it `wmap.py`.

2. **Make the script executable** (optional):
   If you're using a Unix-based system (like Linux or macOS), you can make the script executable:
   ```bash
   chmod +x wmap.py
   ```

### Usage

#### 1. Signing a Document

To sign a document using `wmap`, you need your GitHub username and your SSH private key. The private key is typically located in `~/.ssh/id_rsa` or `~/.ssh/id_ed25519`.

**Command**:
```bash
./wmap.py sign <username> <key> <file>
```

- `<username>`: Your GitHub username.
- `<key>`: Path to your SSH private key.
- `<file>`: Path to the file you want to sign.

**Example**:
```bash
./wmap.py sign johndoe ~/.ssh/id_rsa document.txt
```

This command will create a signed version of `document.txt` and save it as `document.txt.wmap`.

#### 2. Verifying a Signed Document

To verify a signed document, you only need the `.wmap` file created in the previous step.

**Command**:
```bash
./wmap.py verify <file>
```

- `<file>`: Path to the signed file (with `.wmap` extension).

**Example**:
```bash
./wmap.py verify document.txt.wmap
```

If the verification is successful, the command will complete without any output. If the verification fails, the script will exit with a non-zero status.

### Detailed Steps

#### Signing a Document

1. **Open your terminal**.
2. **Navigate to the directory containing `wmap.py`**:
   ```bash
   cd /path/to/wmap
   ```
3. **Run the sign command**:
   ```bash
   ./wmap.py sign johndoe ~/.ssh/id_rsa document.txt
   ```

   - Replace `johndoe` with your GitHub username.
   - Replace `~/.ssh/id_rsa` with the path to your SSH private key.
   - Replace `document.txt` with the path to the file you want to sign.

   This will generate `document.txt.wmap` in the same directory.

#### Verifying a Signed Document

1. **Open your terminal**.
2. **Navigate to the directory containing `wmap.py`**:
   ```bash
   cd /path/to/wmap
   ```
3. **Run the verify command**:
   ```bash
   ./wmap.py verify document.txt.wmap
   ```

   - Replace `document.txt.wmap` with the path to your signed file.

   If the signature is valid, the command will complete successfully. If not, it will exit with a non-zero status.

### Troubleshooting

- **Ensure your SSH key is not password-protected**: If your private key is protected with a passphrase, you may need to use `ssh-agent` to manage your keys.
- **Check file paths**: Make sure you provide the correct paths to your SSH key and the files you want to sign/verify.
- **Dependencies**: Ensure `ssh-keygen` is available on your system. It is required for signing and verifying the documents.

### Conclusion

`wmap` is a convenient tool to sign and verify documents using your GitHub SSH keys, providing a way to ensure the authenticity and integrity of your files. By following this tutorial, you should be able to easily integrate `wmap` into your workflow.

If you encounter any issues or have questions, feel free to reach out for support or consult the documentation of the tools involved (`ssh-keygen`, Python, etc.).

## FAQ (Fervently Anticipated Questions)
*Inspired by those of [Hubris][1]*

### Why not just use GPG?
Weren't you just complaining about Perl? Also do you really want to talk
to people who [*voluntarily use GPG*][3]?

### Why not just use S/MIME?
I would love to, I really would. S/MIME could have been a contender.
Holler at me if you can help me make an S/MIME cert with my own private
key material, but signed with a certificate authority that my parents'
phones already trust. I'd toss WMAP in the WTRASHCAN for that.

### Why not just use Signal?
Signal kicks ass. I strongly recommend Signal over WMAP. Moxie even has
a blog post which spells out [why WMAP will never compete with
Signal][4].


<!-- # References -->
[1]: https://github.com/oxidecomputer/hubris/blob/master/FAQ.mkdn
[2]: https://github.com/git/git/search?l=Perl&q=git
[3]: https://moxie.org/2015/02/24/gpg-and-me.html
[4]: https://moxie.org/2022/01/07/web3-first-impressions.html
