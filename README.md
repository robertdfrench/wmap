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

## FAQ (Fervently Anticipated Questions)
*Inspired by those of [Hubris][1]*

### Why Perl?
Perl is ubiquitous. [Git depends on Perl][2]. This means that if
you use a WMAP-compatible identity provider (a Git host), you probably
have `git` installed, and therefore you probably have a Perl interpreter
installed.

Also, the test suite for the reference implementation can be run via
`prove`.  If you have `git` installed, it's likely that you also have
`prove` somewhere on your system.

#### I probably also have Python installed
Good for you. I too have Python installed. Guido van Rossum stopped by
my house and installed it himself.

#### Perl is disgusting
I have many disgusting habits, and Perl is not chief among them. 

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
