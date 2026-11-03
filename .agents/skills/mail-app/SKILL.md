---
name: mail-app
description: Mail app expert that makes sure an email client has every feature people expect - reading, Gmail-style search, attachments, sending, reply and forward, drafts, labels, archive, delete to Trash, read and unread, and stars - and that each one is built correctly (MIME and threading headers, safe HTML, one label model for inbox, archive, trash, star and unread). Use when planning, building, reviewing or writing a roadmap for an email client, webmail, inbox, mailbox or any feature that reads or sends mail, or when the user mentions email, mail, inbox, drafts, labels or threads.
---

# Mail App

An email client is judged against Gmail. Whatever the backend (an IMAP account, the Gmail API, or a store of its own), the client has every feature below. When planning or building mail, check each feature against this list, and do not call the client done while one is missing. A feature the user decides to leave out goes in the roadmap's *Not doing* list with the reason, so it is a decision rather than a gap.

## Required features

| Feature | What the mail client can do |
|---|---|
| Read emails | View message contents, senders, recipients, dates and subjects |
| Search emails | Search your mailbox using Gmail search queries |
| Read attachments | Download and access attached files |
| Send emails | Send messages from your Gmail address |
| Reply and forward | Respond to existing conversations and forward messages |
| Manage drafts | Create, read, update and delete drafts |
| Manage labels | Create, rename, apply and remove labels |
| Archive emails | Remove messages from the inbox without deleting them |
| Delete emails | Move messages to Trash |
| Mark as read/unread | Change message read status |
| Star emails | Add or remove stars |

Where the client sends from its own domains rather than Gmail, "your Gmail address" means each address the mailbox receives mail for.

## Workflow

1. **Map every feature.** In the plan or roadmap, name where each feature is built or why it is not. A roadmap section that ships mail lists the features it delivers.
2. **Model state as labels.** Apply the data model below before writing the first screen; retrofitting it means migrating every message.
3. **Build each feature to its bar** in [Feature bars](#feature-bars), and test each one.
4. **Verify** with the checklist at the end before calling mail work done.

## Data model

* **The raw message is immutable.** Keep each message exactly as received, byte for byte, and derive everything else from it (parsed headers, bodies, search index) in a form that can be rebuilt.
* **State is labels.** Inbox, Sent, Drafts, Trash, Spam, Starred and Unread are system labels, and user labels sit beside them, as Gmail models it. Archive removes Inbox; delete adds Trash and removes Inbox; star adds Starred; mark unread adds Unread. One many-to-many table between messages and labels, and one code path for every one of these actions.
* **Labels are referenced by id,** so renaming never touches the messages they label. Names are unique ignoring case (Unicode, not ASCII), and a slash nests them, as in `Work/Clients`.
* **Threads come from headers.** Group by `References` and `In-Reply-To`, and fall back to the subject without `Re:`, `Fwd:`, `SV:` and `VS:` prefixes, within a few days, for clients that drop the headers. A thread is unread when any message in it is, and starred when any message in it is.
* **Envelope data is kept.** The envelope recipients (the only record of Bcc), the envelope sender and the sending server are stored when mail arrives; they cannot be recovered from the message later.

## Feature bars

**Read emails.** Parse MIME fully: `multipart/alternative`, `related` and `mixed`, RFC 2047 encoded words in headers, quoted-printable and base64, and charsets beyond UTF-8 (ISO-8859-1, windows-1252). Show From, To, Cc, Date in the reader's time zone and language, and Subject; show Bcc only on mail the user sent. Prefer the HTML part, with the plain text part as a fallback. HTML from mail is hostile: render it in a sandboxed `iframe` without `allow-scripts` or `allow-same-origin`, behind a CSP that blocks scripts and remote content, and load remote images only when the user asks, for that message or sender.

**Search emails.** Accept Gmail's query language, not a plain text box: operators, quoted phrases, `OR`, `-` to exclude and parentheses, as in [reference.md](reference.md). Parse the query into a tree, run text terms against a full-text index (SQLite FTS5 or the server's search), and the rest as filters. Like Gmail, leave Trash and Spam out unless the query names them (`in:trash`, `in:spam`, `in:anywhere`). Test words with æ, ø and å, and decide on purpose whether `å` matches `a`. Put the query in the URL so a search can be shared and returned to.

**Read attachments.** List each attachment with its file name (RFC 2231 `filename*` and RFC 2047 names decoded), size and type. Download with `Content-Disposition: attachment` and an RFC 6266 `filename*`, and `X-Content-Type-Options: nosniff`. Never render an attachment as HTML on the app's own origin. Show inline images through their `cid:` references, and keep them out of the attachment list.

**Send emails.** Build an RFC 5322 message: `Message-ID` on the sending domain, `Date`, `From`, `To` and `Cc` (never `Bcc` in the headers; its addresses go only in the envelope), RFC 2047 for non-ASCII names and subjects, and `multipart/alternative` with a plain text part beside any HTML. The From domain has SPF, DKIM and DMARC that align. Sending goes through an outbox with a state (queued, sent, failed), so a retry never sends twice and a failure is shown, not lost. A copy of every sent message is stored and labelled Sent. Offer undo send: hold the message a few seconds before it leaves.

**Reply and forward.** A reply sets `In-Reply-To` to the original's `Message-ID`, and `References` to the original's `References` followed by that `Message-ID`. The subject gets one `Re:` (never `Re: Re:`), the reply goes to `Reply-To` when there is one, and the From address is the one the original was sent to. Reply all adds To and Cc and drops the user's own addresses and duplicates. The quote starts with an attribution line ("On 1 Nov 2026, at 12:00, Ola Nordmann wrote:") and keeps the original. Forward adds `Fwd:`, includes a block with the original From, Date, Subject and To, and carries the original attachments; forwarding as an attachment (`message/rfc822`) is the alternative.

**Manage drafts.** Create, read, update and delete. Save on a short debounce while typing and when leaving the page, so nothing typed is lost. A draft keeps what it replies to and its attachments. Sending a draft creates the sent message and removes the draft in one transaction. A draft opened in two tabs keeps the newer edit and says so; it never silently drops one.

**Manage labels.** Create, rename, apply and remove, on one message, a whole thread or a selection. Renaming keeps every application. Deleting a label removes it from messages and never deletes the messages. A message can carry any number of labels, and `label:` finds them in search.

**Archive emails.** Removes Inbox and nothing else: the message stays in All Mail, in its other labels and in search. Undo restores it.

**Delete emails.** Moves to Trash, never straight to permanent deletion. Trash is emptied of messages older than 30 days, as Gmail does. Restore from Trash, and permanent deletion only from Trash, behind a confirmation that names what is deleted. Deleting a thread trashes every message in it.

**Mark as read/unread.** Opening a message marks it read; marking unread is one action that does not reopen the message. Unread counts per label update at once, and read state applies to a thread as described in the data model.

**Star emails.** Toggles Starred on a message, or on the newest message of a thread; `is:starred` and a Starred view find them.

## Across every feature

* **Bulk actions:** select many messages or threads, and archive, delete, label, star or mark them read or unread at once.
* **Undo** for archive, delete, label changes and send, as a toast that names the action.
* **Keyboard shortcuts,** as in Gmail: `c` compose, `r` reply, `a` reply all, `f` forward, `e` archive, `#` delete, `s` star, `Shift+U` mark unread, `Shift+I` mark read, `/` search, `j` and `k` to move between threads. They never fire while the user types in a field.
* **States:** an empty inbox, an empty search, a message still loading, a send that failed, and very long subjects and threads all have a designed state; follow the `web-ui` skill.

## Before calling mail work done

Copy and tick:

```
- [ ] Every feature in the table is built, or in Not doing with a reason
- [ ] Inbox, archive, trash, spam, star, unread and user labels share one label model
- [ ] Raw messages are stored unmodified; envelope recipients are kept
- [ ] HTML mail renders sandboxed, remote images off by default
- [ ] Search parses Gmail operators and leaves out Trash and Spam by default
- [ ] Replies set In-Reply-To and References; threads group by them
- [ ] Sending goes through an outbox, a retry never sends twice, Sent keeps a copy
- [ ] Drafts save as the user types and are removed when sent, in one transaction
- [ ] Delete goes to Trash, which is emptied after 30 days
- [ ] Each feature has a test, with æ, ø and å in names, subjects and search
```
