# Trello Tool

A secure, deterministic, and production-ready tool for interacting with the Trello REST API. This tool enables AI agents to perform board, list, card, and member operations in a safe and observable manner.

## Features

- **Secure by Design**: Input sanitization, least-privilege API access, and explicit permission boundaries
- **Structured I/O**: JSON Schema validation for all inputs and outputs
- **Observable**: Structured logging, execution metrics, and tracing support
- **Resilient**: Automatic retries with exponential backoff, timeout handling
- **Type-Safe**: Strong input validation and clear error messages

## Supported Operations

### Boards
- `get_boards` - List all boards for the authenticated user
- `get_board` - Get details for a specific board

### Lists
- `get_lists` - Get all lists on a board

### Cards
- `get_cards` - Get cards from a list or board
- `get_card` - Get details for a specific card
- `create_card` - Create a new card in a list
- `update_card` - Update card properties (name, description, due date, position)
- `move_card` - Move a card to a different list
- `delete_card` - Permanently delete a card (requires confirmation)

### Comments
- `add_comment` - Add a comment to a card

### Members
- `get_members` - Get members of a board or card

### Search
- `search` - Search across boards, cards, and other Trello objects

## Installation

### Prerequisites

- Ruby 2.7 or higher
- Trello API credentials (see Setup below)

### Setup

1. **Get your Trello API credentials**:
   - Visit https://trello.com/app-key to get your API key
   - Generate a token by clicking the "Token" link on that page

2. **Set environment variables**:
   ```bash
   export TRELLO_API_KEY="your_api_key_here"
   export TRELLO_API_TOKEN="your_token_here"
   ```

3. **Run the tool**:
   ```bash
   echo '{"operation": "get_boards"}' | ruby tool.rb
   ```

## Usage

The tool accepts JSON input via stdin and outputs JSON to stdout.

### Input Format

```json
{
  "operation": "operation_name",
  "params": {
    "param1": "value1",
    "param2": "value2"
  },
  "api_key": "optional_api_key",
  "api_token": "optional_api_token"
}
```

### Output Format

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
    "timestamp": "2024-01-15T10:30:00.000Z"
  }
}
```

## Examples

### Get All Boards

```bash
echo '{"operation": "get_boards"}' | ruby tool.rb
```

### Get Lists on a Board

```bash
echo '{"operation": "get_lists", "params": {"board_id": "5f3c2b1a4e9f8b2e1c3d4e5f"}}' | ruby tool.rb
```

### Create a Card

```bash
echo '{
  "operation": "create_card",
  "params": {
    "list_id": "5f3c2b1a4e9f8b2e1c3d4e5g",
    "name": "Implement new feature",
    "desc": "Description of the feature",
    "due": "2024-02-01T12:00:00.000Z"
  }
}' | ruby tool.rb
```

### Move a Card

```bash
echo '{
  "operation": "move_card",
  "params": {
    "card_id": "5f3c2b1a4e9f8b2e1c3d4e5h",
    "list_id": "5f3c2b1a4e9f8b2e1c3d4e5i",
    "pos": "top"
  }
}' | ruby tool.rb
```

### Search Trello

```bash
echo '{
  "operation": "search",
  "params": {
    "query": "project roadmap",
    "model_types": "cards,boards"
  }
}' | ruby tool.rb
```

## Error Handling

The tool returns structured errors with machine-readable codes:

| Code | Description | Retryable |
|------|-------------|-----------|
| `AUTHENTICATION_ERROR` | Invalid API credentials | No |
| `NOT_FOUND` | Resource does not exist | No |
| `VALIDATION_ERROR` | Invalid input parameters | No |
| `RATE_LIMIT_ERROR` | API rate limit exceeded | Yes |
| `HTTP_ERROR` | API returned error status | Depends on status |
| `INTERNAL_ERROR` | Unexpected tool error | Yes |
| `PARSE_ERROR` | Invalid JSON response | Yes |

## Configuration

### Manifest

The `manifest.yaml` file contains:
- Operation definitions
- Permission boundaries
- Timeout and retry policies
- Safety classifications

### Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TRELLO_API_KEY` | Yes | Trello API key |
| `TRELLO_API_TOKEN` | Yes | Trello API token |

### Timeouts

- Connection timeout: 10 seconds
- Read timeout: 30 seconds
- Total execution timeout: 60 seconds

### Retries

- Maximum attempts: 3
- Backoff: Exponential
- Initial delay: 1000ms
- Only retryable errors are retried

## Security

See [SECURITY.md](SECURITY.md) for detailed security information.

### Key Security Features

- All inputs are sanitized and validated
- No shell injection vulnerabilities
- No filesystem access required
- Network restricted to `api.trello.com:443`
- Secrets passed via environment variables only
- ID validation prevents injection attacks

## Testing

Run the test suite:

```bash
cd tests
ruby test_trello_tool.rb
```

## Limitations

- Trello API rate limits apply (100 requests per 10 seconds per token)
- Card names limited to 16,384 characters
- ID fields limited to 64 characters
- Maximum query length: 1000 characters

## Changelog

### 1.0.0
- Initial release
- Support for boards, lists, cards, comments, members, and search
- Full error handling and retry logic
- Schema validation
- Comprehensive documentation

## License

MIT License - See LICENSE file for details

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## Support

For issues or questions:
- Open an issue on the project repository
- Check Trello API documentation: https://developer.atlassian.com/cloud/trello/

## Architecture

```
trello/
├── tool.rb                 # Main tool implementation
├── manifest.yaml           # Tool configuration and metadata
├── schema/
│   ├── input.schema.json   # JSON Schema for input validation
│   └── output.schema.json  # JSON Schema for output validation
├── prompts/               # LLM prompt templates (if applicable)
├── tests/                 # Test suite
├── examples/              # Example usage scripts
├── README.md              # This file
└── SECURITY.md            # Security documentation
```

## Machine-Readable Metadata

This tool exposes structured metadata for agent consumption:

- **Manifest**: `manifest.yaml` - Complete capability and permission definitions
- **Input Schema**: `schema/input.schema.json` - Validated input structure
- **Output Schema**: `schema/output.schema.json` - Guaranteed output structure

The tool is compatible with:
- MCP (Model Context Protocol)
- OpenAI Function Calling
- LangChain Tools
- Claude Tool Use
