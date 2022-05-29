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
    "subject": "https://example.org/alice/blog/2022-05-01-hiking-gsmnp",
    "body": "Cool pic of Mt. Le Conte!",
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


#### Normal Form
The *normal form* of a WMAP message is an unambiguous representation of
the message structure, so that the sender and the receiver can agree on
the signature. Consider the following two JSON files:

```
# one.json
{"a": 1, "b": 2}

# two.json
{
    "b": 2,
    "a": 1
}
```

Clearly, these two files represent the same *object*, but since they
contain a different array of bytes, a signature that's valid for one
won't be valid for the other. So we need to agree on a unified way to
represent WMAP documents, at least when signing or validating them:

```json
{"body":"BODY","from":"FROM","subject":"SUBJECT","to":"TO","wmap":"WMAP"}
```

That is, we strip out all whitespace and sort the fields alphabetically,
omitting the `signature` field.  We even remove the trailing newline
from the end of the document!  Of course, if there's whitespace in
`BODY`, we still allow that -- that's a necessary part of the message
being sent. Putting a document in *normal form* before signing or
validating it will reduce errors that could arise from ambiguous
formatting.


#### `from` Field
We include the `from` field in the document, that way the author
acknowledges they are sending with the listed identity, and so that the
recipient can infer where to get a list of authorized keys.


#### `to` Field
The `to` field is signed in order to prevent mis-appropriation attacks.
For example, if I sign the message "I'm leaving!" without specifying a
recipient, an attacker might attempt to forward it to my employer. This
would be bad if I come back from vacation to find that my boss thinks
I've resigned.


#### `body` Field
This is intended to be the application-specific content of the WMAP
message. In general, it can be plain text, but you may devise and
application where specific formats and structures are required. It must
always be a single JSON string, so complex documents should agree on a
plaintext encoding like base64.


#### `subject` Field
Like the `to` field, `subject` helps prevent mis-appropriation attacks.
For example, if I sign the message "Congratulations!" with the intent of
responding to my mother's post about her upcoming retirement, an
attacker could replay that message against a separate post grieving the
loss of a loved one. 


#### `wmap` Field
This specifies the version of the WMAP protocol that the message was
written in; if the protocol changes in the future, signing the intended
version will prevent a replay attack from taking advantage of potential
ambiguities between the old and new formats.


#### `signature` Field
This contains the base64-encoded SSH signature of the *normal form* of
the document. Of course, that means that the `signature` field itself
can't be included in the *normal form*. 
