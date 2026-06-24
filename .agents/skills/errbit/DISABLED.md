---
name: errbit
description: Interface with Errbit error tracking instance at https://errbit.dialogapi.no. Use when the user asks about error tracking, viewing problems, accessing error reports, or mentions errbit.dialogapi.no.
---

# Errbit Tool Access

## Overview

This skill provides access to the Errbit error tracking API through the errbit tool located at `~/.agents/tools/errbit/`.

Errbit is an open-source error catcher that is Airbrake API compliant. The instance at `https://errbit.dialogapi.no` tracks errors and exceptions from applications.

**Important:** Each registered app in Errbit has its own unique API key. You must provide the API key for the specific app you want to access in every request.

## Authentication

**Every operation requires an `api_key` parameter.** Each app in Errbit has its own API key, and you must use the key of the app whose data you want to access.

To find an app's API key:
1. Log into the Errbit instance
2. Navigate to the app
3. Go to Settings → API Key

## Usage

Invoke the errbit tool using bash:

```bash
echo '{"action": "OPERATION", "api_key": "APP_API_KEY", "param1": "value1"}' | ruby ~/.agents/tools/errbit/tool.rb
```

## Available Operations

### list_problems
List all problems (errors) for a specific app.

**Required Parameters:**
- `api_key`: The API key of the app to query

**Optional Parameters:**
- `start_date`: Filter problems that occurred after this date (ISO 8601 format)
- `end_date`: Filter problems that occurred before this date (ISO 8601 format)

**Example:**
```bash
echo '{
  "action": "list_problems",
  "api_key": "your-app-api-key",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-12-31T23:59:59Z"
}' | ruby ~/.agents/tools/errbit/tool.rb
```

### get_problem
Get details of a specific problem.

**Required Parameters:**
- `api_key`: The API key of the app that owns the problem
- `problem_id`: The ID of the problem to retrieve

**Example:**
```bash
echo '{
  "action": "get_problem",
  "api_key": "your-app-api-key",
  "problem_id": "552941336a756e4e71012345"
}' | ruby ~/.agents/tools/errbit/tool.rb
```

### list_notices
List all notices (individual error occurrences) for a specific app.

**Required Parameters:**
- `api_key`: The API key of the app to query

**Optional Parameters:**
- `start_date`: Filter notices created after this date (ISO 8601 format)
- `end_date`: Filter notices created before this date (ISO 8601 format)

**Example:**
```bash
echo '{
  "action": "list_notices",
  "api_key": "your-app-api-key",
  "start_date": "2024-01-01T00:00:00Z",
  "end_date": "2024-12-31T23:59:59Z"
}' | ruby ~/.agents/tools/errbit/tool.rb
```

### get_stats
Get statistics for a specific app.

**Required Parameters:**
- `api_key`: The API key of the app to get statistics for

**Example:**
```bash
echo '{
  "action": "get_stats",
  "api_key": "your-app-api-key"
}' | ruby ~/.agents/tools/errbit/tool.rb
```

**Response Example:**
```json
{
  "name": "sample app",
  "id": "552941336a756e4e71012345",
  "last_error_time": "2025-04-12T08:43:47.480+00:00",
  "unresolved_errors": 4
}
```

### list_comments
List all comments on a specific problem.

**Required Parameters:**
- `api_key`: The API key of the app that owns the problem
- `problem_id`: The ID of the problem

**Example:**
```bash
echo '{
  "action": "list_comments",
  "api_key": "your-app-api-key",
  "problem_id": "552941336a756e4e71012345"
}' | ruby ~/.agents/tools/errbit/tool.rb
```

### create_comment
Create a new comment on a problem.

**Required Parameters:**
- `api_key`: The API key of the app that owns the problem
- `problem_id`: The ID of the problem to comment on
- `body`: The comment text

**Example:**
```bash
echo '{
  "action": "create_comment",
  "api_key": "your-app-api-key",
  "problem_id": "552941336a756e4e71012345",
  "body": "Investigating this issue"
}' | ruby ~/.agents/tools/errbit/tool.rb
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

## Workflow

1. **Ask the user for the app's API key** if not provided (each app has its own key)
2. **Choose the appropriate operation** from the list above
3. **Execute via bash** using the command patterns shown
4. **Parse the JSON output** and present results to the user

## Error Handling

If the tool returns an error:
- Verify you have the correct `api_key` for the app you're trying to access
- Check that the `problem_id` is correct
- Ensure you have permission to access the resource

Common HTTP status codes:
- `200-299`: Success
- `401`: Unauthorized - Invalid API key
- `404`: Not found
- `422`: Unprocessable entity

## API Endpoints

The tool communicates with the following Errbit API v1 endpoints:

- `GET /api/v1/problems` - List problems
- `GET /api/v1/problems/:id` - Get specific problem
- `GET /api/v1/notices` - List notices
- `GET /api/v1/stats/app` - Get app statistics
- `GET /api/v1/problems/:problem_id/comments` - List comments
- `POST /api/v1/problems/:problem_id/comments` - Create comment
