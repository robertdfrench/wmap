## WMAP
*The Web-based Message Authentication Protocol*

WMAP lets you validate messages against your friends' SSH pubkeys.
GitHub, GitLab, and BitBucket all post SSH public keys in known
locations: simply sign your messages as `https://github.com/<USERNAME>`
and your friends will be able to verify their integrity.

WMAP messages have the following structure:
```json
{
    "from": "https://github.com/robertdfrench",
    "to": "https://example.org/alice",
    "message": "Hello!",
    "signature": "U1NIU0lHAA...jiam+SDCzaoFiSvw==",
    "wmap": "v0.1.0"
}
```
where `from` is the URL to your page on a WMAP-compatible website, `to`
is the URL of the recipient's page, `message` is a string that you would
like to send, `signature` is a WMAP-specific SSH signature, and `wmap`
is the version of the protocol we're using.


### Informal Specification


#### Profile URL
A *profile URL* is an `https://` url which is valid, and for which a
corresponding *pubkey URL* exists:

* Profile URL: `https://example.org/alice`
* Pubkey URL: `https://example.org/alice.keys`

In WMAP, a *profile URL* is roughly equivalent to a username or an email
address: if I want to refer to someone, I do it by using their *profile
URL*.


#### Pubkey URL
A *pubkey URL* is an `https://` url which is obtained by appending
the string ".keys" to a user's profile URL. This URL should support
`GET` queries, and should return a `text/plain` document containing a
list of SSH public keys in the [`authorized_keys` file
format](https://man.openbsd.org/sshd#AUTHORIZED_KEYS_FILE_FORMAT).
