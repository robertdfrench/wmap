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
    "to": "https://example.org/world",
    "when": "2022-05-22T14:50:56-04:00",
    "body": "Hello!"
}
```
where `from` is the URL to your page on a WMAP-compatible website, `to`
is the URL of the recipient's page, `when` is an ISO8601 timestamp, and
`body` is a string that you would like to send.
