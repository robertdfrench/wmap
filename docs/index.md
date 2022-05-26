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
