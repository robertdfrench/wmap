# WMAP
*The Web-based Message Authentication Protocol*

WMAP lets you validate messages against your friends' SSH pubkeys.
Since your GitHub keys are stored in a [known
location](https://github.com/robertdfrench.keys), signing documents with
these keys makes it easy for your friends to verify their integrity (and
the integrity of the documents!).

This repository contains a reference implementation for a protocol which
can be used for moderately trustworthy internet communication. Many such
protocols already exist, the goal of this one is to see what can be done
with tools that software engineers are likely to already have lying
around: `git`, `ssh`, etc.

Here's how it works at a high level:

```mermaid
sequenceDiagram
    Alice->>GitHub: Upload SSH Pubkey
    Alice->>Alice: Sign Message for Bob
    Alice->>Bob: Send Message to Bob
    Bob->>GitHub: Fetch Alice's Pubkey
    Bob->>Bob: Verify Message Came from Alice
```

## Tutorial
First, clone this repository!

### Signing a Document
In the repo, run `./wmap sign <username> <key> <file>`. These arguments
are:
- `<username>`: Your GitHub username.
- `<key>`: Path to your SSH private key.
- `<file>`: Path to the file you want to sign.

Now you've got a signed version of `<file>` called `<file>.wmap`, which
you can send to your friends!

### Verifying a Message
To verify a signed document, you only need the `.wmap` file created in the previous step.

```bash
./wmap verify <file>.wmap
```

where `<file>.wmap` is the path to the signed WMAP file.  If the
verification is successful, the command will complete without any
output. If the verification fails, the script will exit with a non-zero
status.

### Extracting a Document from a Verified Message
If you've received a WMAP message from a friend, they probably want you
to read the message inside. To extract this message, use the `extract`
command:

```bash
./wmap extract <file>.wmap
```

This will print the body of `<file>.wmap` to stdout.

Keep in mind that this command will fail if the wmap file cannot be
verified.  If you need to extract it anyways, you can do this:

```bash
./wmap extract --skip-validation <file>.wmap
```

## Message Structure
WMAP messages have the following structure:
```json
{
    "profile": "robertdfrench",
    "body": "SGVsbG8sIHdvcmxkLgo=",
    "signature": "U1NIU0lHAA...jiam+SDCzaoFiSvw==",
}
```
where `profile` is your GitHub username, `body` is a base64-encoded copy
of the data you'd like to send, and `signature` is a WMAP-specific SSH
signature. A WMAP file contains everything your friends need to verify
the integrity of your messages!

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
