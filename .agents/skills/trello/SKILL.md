---
name: trello
description: Interface with Trello boards, cards, and lists via the Trello REST API. Use when the user asks about Trello cards, boards, lists, comments, or mentions the trello tool. Automatically invoked when trello URLs or card IDs are mentioned.
---

# Trello Tool Access

## Overview

This skill provides access to the Trello API through the trello tool located at `~/.agents/tools/trello/`.

## Requirements

The following environment variables must be set:
- `TRELLO_API_KEY` - Your Trello API key
- `TRELLO_API_TOKEN` - Your Trello API token

## Usage

Invoke the trello tool using bash:

```bash
ruby ~/.agents/tools/trello/tool.rb '{"action": "OPERATION", "param1": "value1"}'
```

## Available Operations

### get_boards
Get all boards for the authenticated user.
```bash
ruby ~/.agents/tools/trello/tool.rb '{"action": "get_boards"}'
```

### get_board
Get a specific board by ID.
```bash
ruby ~/.agents/tools/trello/tool.rb '{"action": "get_board", "board_id": "BOARD_ID"}'
```

### get_lists
Get all lists on a board.
```bash
ruby ~/.agents/tools/trello/tool.rb '{"action": "get_lists", "board_id": "BOARD_ID"}'
```

### get_cards
Get cards from a list or board.
```bash
# From a list
ruby ~/.agents/tools/trello/tool.rb '{"action": "get_cards", "list_id": "LIST_ID"}'

# From a board
ruby ~/.agents/tools/trello/tool.rb '{"action": "get_cards", "board_id": "BOARD_ID"}'
```

### get_card
Get a specific card by ID. Card IDs can be extracted from URLs like `https://trello.com/c/CARD_ID/...`
```bash
ruby ~/.agents/tools/trello/tool.rb '{"action": "get_card", "card_id": "CARD_ID"}'
```

### create_card
Create a new card in a list.
```bash
ruby ~/.agents/tools/trello/tool.rb '{
  "action": "create_card",
  "list_id": "LIST_ID",
  "name": "Card Name",
  "desc": "Card description",
  "due": "2025-05-15T10:00:00Z",
  "pos": "top"
}'
```

### update_card
Update an existing card.
```bash
ruby ~/.agents/tools/trello/tool.rb '{
  "action": "update_card",
  "card_id": "CARD_ID",
  "name": "New Name",
  "desc": "New description"
}'
```

### move_card
Move a card to a different list.
```bash
ruby ~/.agents/tools/trello/tool.rb '{
  "action": "move_card",
  "card_id": "CARD_ID",
  "list_id": "DESTINATION_LIST_ID",
  "pos": "top"
}'
```

### delete_card
Delete a card permanently. Requires confirmation.
```bash
ruby ~/.agents/tools/trello/tool.rb '{
  "action": "delete_card",
  "card_id": "CARD_ID"
}'
```

### add_comment
Add a comment to a card.
```bash
ruby ~/.agents/tools/trello/tool.rb '{
  "action": "add_comment",
  "card_id": "CARD_ID",
  "text": "Comment text here"
}'
```

### get_members
Get members of a board or card.
```bash
ruby ~/.agents/tools/trello/tool.rb '{
  "action": "get_members",
  "board_id": "BOARD_ID"
}'
```

### search
Search across Trello.
```bash
ruby ~/.agents/tools/trello/tool.rb '{
  "action": "search",
  "query": "search term",
  "model_types": "cards,boards",
  "partial": true
}'
```

## Extracting Card IDs from URLs

Trello card URLs follow the pattern: `https://trello.com/c/CARD_ID/card-name`

Extract the `CARD_ID` (the part after `/c/` and before the next `/`).

Example:
- URL: `https://trello.com/c/QKEtFT2l/98-bug-add-test`
- Card ID: `QKEtFT2l`

## Workflow

1. **Check environment variables** are set
2. **Extract card/board/list ID** from user input or URLs
3. **Choose the appropriate operation** from the list above
4. **Execute via bash** using the command patterns shown
5. **Parse the JSON output** and present results to the user

## Error Handling

If the tool returns an error:
- Verify `TRELLO_API_KEY` and `TRELLO_API_TOKEN` are set
- Check that the card/board/list ID is correct
- Ensure you have permission to access the resource
