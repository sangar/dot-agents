# Gmail search syntax

The query language a mail client's search accepts. Terms are joined with AND unless `OR` or `{ }` joins them, and matching ignores case.

## Who and what

| Operator | Finds | Example |
|---|---|---|
| `from:` | Sender | `from:ola@example.com`, `from:me` |
| `to:` | A recipient in To | `to:gard@gasamedia.no` |
| `cc:` / `bcc:` | A recipient in Cc or Bcc | `cc:kari` |
| `deliveredto:` | An envelope recipient | `deliveredto:gard+news@gasamedia.no` |
| `subject:` | Words in the subject | `subject:faktura` |
| `"..."` | An exact phrase | `"møte i morgen"` |
| `list:` | Mail from a mailing list | `list:info@example.com` |
| `rfc822msgid:` | One message by its `Message-ID` | `rfc822msgid:<hei@example.com>` |

## Combining

| Syntax | Meaning | Example |
|---|---|---|
| `a b` | Both | `from:ola faktura` |
| `OR` or `{a b}` | Either | `from:ola OR from:kari`, `{from:ola from:kari}` |
| `-` | Not | `faktura -from:ola` |
| `( )` | Group | `subject:(middag film)` |
| `AROUND n` | Words within n words of each other | `møte AROUND 5 fredag` |

## State and place

| Operator | Finds |
|---|---|
| `in:inbox`, `in:sent`, `in:drafts`, `in:trash`, `in:spam` | Messages in that place |
| `in:anywhere` | Everything, Trash and Spam included |
| `is:unread`, `is:read` | By read state |
| `is:starred` | Starred messages |
| `label:` | A label |
| `has:userlabels`, `has:nouserlabels` | Messages with or without user labels |

Without `in:trash`, `in:spam` or `in:anywhere`, a search leaves out Trash and Spam.

## Attachments and size

| Operator | Finds | Example |
|---|---|---|
| `has:attachment` | Messages with attachments | `has:attachment from:ola` |
| `filename:` | An attachment name or type | `filename:pdf`, `filename:faktura.pdf` |
| `larger:`, `smaller:` | By size, with `K` or `M` | `larger:10M` |
| `size:` | Larger than a size in bytes | `size:1000000` |

## Dates

| Operator | Finds | Example |
|---|---|---|
| `after:`, `before:` | By date, `YYYY/MM/DD` | `after:2026/10/01 before:2026/11/01` |
| `older:`, `newer:` | The same as `before:` and `after:` | `newer:2026/10/01` |
| `older_than:`, `newer_than:` | Relative, in `d`, `m` or `y` | `newer_than:7d`, `older_than:1y` |

Read dates in the user's time zone, so `after:2026/11/01` starts at midnight where the user is.
