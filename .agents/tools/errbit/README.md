# Errbit Client Tool

A Ruby-based client tool for interacting with the Errbit error tracking API.

## Overview

This tool provides a programmatic interface to access an Errbit instance at `https://errbit.dialogapi.no`. Errbit is an open-source error catcher that is Airbrake API compliant.

**Important:** In Errbit, each registered app has its own unique API key. You must use the API key of the specific app whose data you want to access.

## Supported Actions

### `list_problems`
List all problems (errors) for a specific app.

**Parameters:**
- `api_key` (required): The API key of the app to query
- `start_date` (optional): Filter problems that occurred after this date (ISO 8601 format)
- `end_date` (optional): Filter problems that occurred before this date (ISO 8601 format)

**Example:**
```bash
echo '{"action": "list_problems", "api_key": "your-app-api-key"}' | ruby ~/.agents/tools/errbit/tool.rb
```

With date filters:
```bash
echo '{"action": "list_problems", "api_key": "your-app-api-key", "start_date": "2024-01-01T00:00:00Z", "end_date": "2024-12-31T23:59:59Z"}' | ruby ~/.agents/tools/errbit/tool.rb
```

### `get_problem`
Get details of a specific problem.

**Parameters:**
- `api_key` (required): The API key of the app that owns the problem
- `problem_id` (required): The ID of the problem to retrieve

**Example:**
```bash
echo '{"action": "get_problem", "api_key": "your-app-api-key", "problem_id": "552941336a756e4e71012345"}' | ruby ~/.agents/tools/errbit/tool.rb
```

### `list_notices`
List all notices (individual error occurrences) for a specific app.

**Parameters:**
- `api_key` (required): The API key of the app to query
- `start_date` (optional): Filter notices created after this date (ISO 8601 format)
- `end_date` (optional): Filter notices created before this date (ISO 8601 format)

**Example:**
```bash
echo '{"action": "list_notices", "api_key": "your-app-api-key"}' | ruby ~/.agents/tools/errbit/tool.rb
```

With date filters:
```bash
echo '{"action": "list_notices", "api_key": "your-app-api-key", "start_date": "2024-01-01T00:00:00Z", "end_date": "2024-12-31T23:59:59Z"}' | ruby ~/.agents/tools/errbit/tool.rb
```

### `get_stats`
Get statistics for a specific app.

**Parameters:**
- `api_key` (required): The API key of the app to get statistics for

**Example:**
```bash
echo '{"action": "get_stats", "api_key": "your-app-api-key"}' | ruby ~/.agents/tools/errbit/tool.rb
```

**Response:**
```json
{
  "name": "sample app",
  "id": "552941336a756e4e71012345",
  "last_error_time": "2025-04-12T08:43:47.480+00:00",
  "unresolved_errors": 4
}
```

### `list_comments`
List all comments on a specific problem.

**Parameters:**
- `api_key` (required): The API key of the app that owns the problem
- `problem_id` (required): The ID of the problem

**Example:**
```bash
echo '{"action": "list_comments", "api_key": "your-app-api-key", "problem_id": "552941336a756e4e71012345"}' | ruby ~/.agents/tools/errbit/tool.rb
```

### `create_comment`
Create a new comment on a problem.

**Parameters:**
- `api_key` (required): The API key of the app that owns the problem
- `problem_id` (required): The ID of the problem to comment on
- `body` (required): The comment text

**Example:**
```bash
echo '{"action": "create_comment", "api_key": "your-app-api-key", "problem_id": "552941336a756e4e71012345", "body": "Investigating this issue"}' | ruby ~/.agents/tools/errbit/tool.rb
```

## Authentication

**Each app in Errbit has its own API key.** You must provide the API key for the specific app you want to access via the `api_key` parameter in every request.

To find your app's API key:
1. Log into your Errbit instance
2. Navigate to the app
3. Go to Settings → API Key

You can also set the API key via the `ERRBIT_API_KEY` environment variable.

## Configuration

### Environment Variables
- `ERRBIT_API_KEY` (optional): Default API key to use if not provided in request
- `ERRBIT_BASE_URL` (optional): Override the default errbit instance URL

**Example using environment variable:**
```bash
export ERRBIT_API_KEY="your-app-api-key"
echo '{"action": "list_problems"}' | ruby ~/.agents/tools/errbit/tool.rb
```

### Custom Base URL
```bash
echo '{"action": "get_stats", "api_key": "your-app-api-key", "base_url": "https://errbit.your-domain.com"}' | ruby ~/.agents/tools/errbit/tool.rb
```

## Tool Usage

### Direct Command Line

Run the tool by piping JSON input to the Ruby script:

```bash
echo '{"action": "ACTION_NAME", "api_key": "your-app-api-key"}' | ruby ~/.agents/tools/errbit/tool.rb
```

### As an Agent Tool

This tool can be integrated with agent systems that support tool invocation:

```json
{
  "tool": "errbit",
  "input": {
    "action": "list_problems",
    "api_key": "your-app-api-key",
    "start_date": "2024-01-01T00:00:00Z"
  }
}
```

## Response Format

All responses follow this structure:

```json
{
  "success": true|false,
  "status": 200,
  "data": { ... },
  "error": "Error message if failed",
  "details": { ... }
}
```

## API Endpoints

The tool communicates with the following Errbit API v1 endpoints:

- `GET /api/v1/problems` - List problems
- `GET /api/v1/problems/:id` - Get specific problem
- `GET /api/v1/notices` - List notices
- `GET /api/v1/stats/app` - Get app statistics
- `GET /api/v1/problems/:problem_id/comments` - List comments
- `POST /api/v1/problems/:problem_id/comments` - Create comment

## Security

- All HTTPS requests use SSL verification
- API keys are passed as query parameters (`auth_token`)
- No local filesystem access required
- Network access restricted to `errbit.dialogapi.no`

## Error Handling

The tool handles these HTTP status codes:
- `200-299`: Success
- `401`: Unauthorized - Invalid API key
- `404`: Not found
- `422`: Unprocessable entity
- Others: Generic HTTP error

Timeout handling:
- Open timeout: 10 seconds
- Read timeout: 30 seconds

## Dependencies

- Ruby 2.7+
- Standard library only (net/http, json, uri, openssl)

## Version

1.1.0
