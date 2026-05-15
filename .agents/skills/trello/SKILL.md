---
name: trello
description: Interface with Trello boards, cards, and lists via the Trello REST API. Use when the user asks about Trello cards, boards, lists, comments, or mentions the trello tool. Automatically invoked when trello URLs or card IDs are mentioned.
---

# Trello Tool Access

## Overview

This skill provides access to the Trello API through the trello tool located at `~/.agents/tools/trello/`.

## Requirements

The following environment variables must be set:
- `TRELLO_API_KEY` - Your Trello API key (get from https://trello.com/app-key)
- `TRELLO_API_TOKEN` - Your Trello API token (generate from the app-key page)

## Usage

Invoke the trello tool using bash with JSON input via stdin:

```bash
echo '{"operation": "OPERATION_NAME", "params": {"param1": "value1"}}' | ruby ~/.agents/tools/trello/tool.rb
```

### Input Format

```json
{
  "operation": "operation_name",
  "params": {
    "param1": "value1",
    "param2": "value2"
  },
  "api_key": "optional_override",
  "api_token": "optional_override"
}
```

### Output Format

The tool returns structured JSON:

```json
{
  "success": true|false,
  "operation": "operation_name",
  "data": { ... },
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message",
    "retryable": true|false
  },
  "metadata": {
    "execution_ms": 123.45,
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

## Available Operations

### get_boards
Get all boards for the authenticated user.
```bash
echo '{"operation": "get_boards"}' | ruby ~/.agents/tools/trello/tool.rb
```

### get_board
Get a specific board by ID.
```bash
echo '{"operation": "get_board", "params": {"board_id": "BOARD_ID"}}' | ruby ~/.agents/tools/trello/tool.rb
```

### get_lists
Get all lists on a board.
```bash
echo '{"operation": "get_lists", "params": {"board_id": "BOARD_ID"}}' | ruby ~/.agents/tools/trello/tool.rb
```

### get_cards
Get cards from a list or board.
```bash
# From a list
echo '{"operation": "get_cards", "params": {"list_id": "LIST_ID"}}' | ruby ~/.agents/tools/trello/tool.rb

# From a board
echo '{"operation": "get_cards", "params": {"board_id": "BOARD_ID"}}' | ruby ~/.agents/tools/trello/tool.rb
```

### get_card
Get a specific card by ID. Card IDs can be extracted from URLs like `https://trello.com/c/CARD_ID/...`
```bash
echo '{"operation": "get_card", "params": {"card_id": "CARD_ID"}}' | ruby ~/.agents/tools/trello/tool.rb
```

### create_card
Create a new card in a list.
```bash
echo '{
  "operation": "create_card",
  "params": {
    "list_id": "LIST_ID",
    "name": "Card Name",
    "desc": "Card description",
    "due": "2025-05-15T10:00:00Z",
    "pos": "top"
  }
}' | ruby ~/.agents/tools/trello/tool.rb
```

### update_card
Update an existing card.
```bash
echo '{
  "operation": "update_card",
  "params": {
    "card_id": "CARD_ID",
    "name": "New Name",
    "desc": "New description",
    "due": "2025-06-01T12:00:00Z",
    "pos": "top",
    "list_id": "NEW_LIST_ID"
  }
}' | ruby ~/.agents/tools/trello/tool.rb
```

### move_card
Move a card to a different list.
```bash
echo '{
  "operation": "move_card",
  "params": {
    "card_id": "CARD_ID",
    "list_id": "DESTINATION_LIST_ID",
    "pos": "top"
  }
}' | ruby ~/.agents/tools/trello/tool.rb
```

### delete_card
Delete a card permanently (destructive operation).
```bash
echo '{
  "operation": "delete_card",
  "params": {
    "card_id": "CARD_ID"
  }
}' | ruby ~/.agents/tools/trello/tool.rb
```

### add_comment
Add a comment to a card.
```bash
echo '{
  "operation": "add_comment",
  "params": {
    "card_id": "CARD_ID",
    "text": "Comment text here"
  }
}' | ruby ~/.agents/tools/trello/tool.rb
```

### get_members
Get members of a board or card.
```bash
# Get board members
echo '{"operation": "get_members", "params": {"board_id": "BOARD_ID"}}' | ruby ~/.agents/tools/trello/tool.rb

# Get card members
echo '{"operation": "get_members", "params": {"card_id": "CARD_ID"}}' | ruby ~/.agents/tools/trello/tool.rb
```

### search
Search across Trello.
```bash
echo '{
  "operation": "search",
  "params": {
    "query": "search term",
    "model_types": "cards,boards",
    "partial": true
  }
}' | ruby ~/.agents/tools/trello/tool.rb
```

## Extracting Card IDs from URLs

Trello card URLs follow the pattern: `https://trello.com/c/CARD_ID/card-name`

Extract the `CARD_ID` (the part after `/c/` and before the next `/`).

Example:
- URL: `https://trello.com/c/QKEtFT2l/98-bug-add-test`
- Card ID: `QKEtFT2l`

## Error Handling

The tool returns structured errors with these codes:

| Code | Description | Retryable |
|------|-------------|-----------|
| `AUTHENTICATION_ERROR` | Invalid API credentials | No |
| `NOT_FOUND` | Resource does not exist | No |
| `VALIDATION_ERROR` | Invalid input parameters | No |
| `RATE_LIMIT_ERROR` | API rate limit exceeded | Yes |
| `HTTP_ERROR` | API returned error status | Depends on status |
| `INTERNAL_ERROR` | Unexpected tool error | Yes |
| `PARSE_ERROR` | Invalid JSON response | Yes |

## Workflow

1. **Check environment variables** are set (`TRELLO_API_KEY`, `TRELLO_API_TOKEN`)
2. **Extract card/board/list ID** from user input or URLs
3. **Choose the appropriate operation** from the list above
4. **Execute via bash** using the echo-pipe pattern shown
5. **Parse the JSON output** - check `success` field, then access `data` or handle `error`

## Examples

### Complete Example: Create a Card

```bash
# Set environment variables
export TRELLO_API_KEY="your_key"
export TRELLO_API_TOKEN="your_token"

# Create a card
result=$(echo '{
  "operation": "create_card",
  "params": {
    "list_id": "5f3c2b1a4e9f8b2e1c3d4e5f",
    "name": "New Feature Request",
    "desc": "Description here",
    "pos": "top"
  }
}' | ruby ~/.agents/tools/trello/tool.rb)

# Check if successful
echo "$result" | ruby -rjson -e 'data = JSON.parse(STDIN.read); puts data["success"] ? "Created!" : "Failed: #{data["error"]["message"]}"'
```

### Parse Response Data

```bash
# Get card and extract name
result=$(echo '{"operation": "get_card", "params": {"card_id": "ABC123"}}' | ruby ~/.agents/tools/trello/tool.rb)
echo "$result" | ruby -rjson -e 'data = JSON.parse(STDIN.read); puts data["data"]["name"] if data["success"]'
```

## Tool Specifications

- **Location**: `~/.agents/tools/trello/tool.rb`
- **Language**: Ruby
- **Entry Point**: `tool.rb`
- **Input**: JSON via stdin
- **Output**: JSON to stdout
- **Network**: Only connects to `api.trello.com:443`
- **Timeout**: 60 seconds max execution
- **Retries**: Up to 3 attempts with exponential backoff
- **Rate Limits**: Trello API limits (100 requests per 10 seconds per token)

## Security Notes

- API credentials should be passed via environment variables, not in JSON params
- All IDs are sanitized to prevent injection attacks
- `delete_card` is marked as destructive and requires explicit confirmation
- No filesystem access required
- Network restricted to Trello API only