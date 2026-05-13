---
name: victoria-logs
description: Query and analyze logs from VictoriaLogs instances running in Kubernetes clusters. Use when the user asks about querying logs, analyzing log data, searching logs, or mentions VictoriaLogs, vlogs, or Kubernetes log analysis.
---

# VictoriaLogs Skill

## Overview

This skill enables querying and analyzing logs from VictoriaLogs instances running in Kubernetes clusters using the `vlogs` tool.

## Requirements

**Environment Variables:**
- `VLOGS_SCRUB_KEY` - Required for PII scrubbing. Set a secret key to enable data anonymization.
- `KUBECONFIG` - Optional. Path to Kubernetes config file.

## Usage

Invoke the vlogs tool using bash:

```bash
echo '{"command": "COMMAND", "context": "KUBERNETES_CONTEXT", ...}' | ruby ~/.agents/tools/vlogs/tool.rb
```

Or use the wrapper script directly:

```bash
~/.agents/tools/vlogs/vlogs -c CONTEXT COMMAND [OPTIONS]
```

## Commands

### query - Search Logs

Search log entries matching a query.

```bash
echo '{"command": "query", "context": "production", "query": "level:ERROR", "start": "1h"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

**Parameters:**
- `query` - LogsQL query string (default: `*`)
- `start` - Start time: relative (5m, 1h, 24h) or absolute (2026-03-25T08:00:00Z)
- `end` - End time (default: now)
- `limit` - Maximum results (default: 50)
- `format` - Output format: `json` or `table` (default: `json`)
- `raw` - Disable PII scrubbing (set to true, requires VLOGS_SCRUB_KEY to be unset)

### stats - Aggregation Queries

Run statistical aggregations.

```bash
echo '{"command": "stats", "context": "production", "query": "stats count(*) by (level)"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

### fields - List Available Fields

List field names available in logs.

```bash
echo '{"command": "fields", "context": "production"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

### values - List Field Values

List unique values for a specific field.

```bash
echo '{"command": "values", "context": "production", "field": "level"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

**Parameters:**
- `field` - Required. Field name to get values for

### hits - Log Volume

Show log volume over time.

```bash
echo '{"command": "hits", "context": "production", "field": "level", "start": "24h"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

### cleanup - Stop Port-Forward

Kill the active port-forward process.

```bash
echo '{"command": "cleanup"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

## LogsQL Query Syntax

| Query Pattern | Description |
|--------------|-------------|
| `*` | All logs |
| `level:ERROR` | Error level logs |
| `level:ERROR AND application:make-api` | Errors from specific app |
| `message:"database connection"` | Logs containing phrase |
| `payload.status:500` | HTTP 500 errors |
| `duration_ms:>1000` | Duration > 1000ms |
| `_time:2026-05-13` | Specific date |
| `stats count(*) by (level)` | Count by level |
| `stats avg(duration_ms)` | Average duration |

## Workflows

### Debug Recent Errors

```bash
# Get errors from last 30 minutes
echo '{"command": "query", "context": "production", "query": "level:ERROR", "start": "30m", "format": "table"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

### Check Application Health

```bash
# Error count by application
echo '{"command": "stats", "context": "production", "query": "stats count(*) by (application)", "start": "1h", "format": "table"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

### Performance Analysis

```bash
# Find slow requests
echo '{"command": "query", "context": "production", "query": "duration_ms:>1000", "start": "1h", "format": "table"}' | ruby ~/.agents/tools/vlogs/tool.rb

# Average response time by endpoint
echo '{"command": "stats", "context": "production", "query": "stats avg(duration_ms) by (payload.path)", "start": "1h", "format": "table"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

### Find Field Values

```bash
# List all log levels
echo '{"command": "values", "context": "production", "field": "level"}' | ruby ~/.agents/tools/vlogs/tool.rb

# List all applications
echo '{"command": "values", "context": "production", "field": "application"}' | ruby ~/.agents/tools/vlogs/tool.rb
```

## PII Scrubbing

By default, all output is scrubbed for PII:

- Email addresses → `[EMAIL:HASH]`
- Names (first, last, full, display, user, customer) → `[PII:HASH]`
- Phone numbers → `[PII:HASH]`
- Addresses, city, zip codes → `[PII:HASH]`
- SSN, date of birth → `[PII:HASH]`

To see raw data, use `"raw": true` (requires `VLOGS_SCRUB_KEY` to be unset).

## Error Handling

**"VLOGS_SCRUB_KEY is not set"**
- Set the environment variable: `export VLOGS_SCRUB_KEY="your-secret-key"`
- Or use `"raw": true` to disable scrubbing (exposes real data)

**"Port-forward failed to start"**
- Check if port 9428 is in use: `lsof -ti:9428`
- Run cleanup command to kill orphaned processes

**"kubectl context not found"**
- Verify context exists: `kubectl config get-contexts`
- Use correct context name in the request

## Troubleshooting

1. **Check tool is available:**
   ```bash
   ls ~/.agents/tools/vlogs/
   ```

2. **Test with simple query:**
   ```bash
   echo '{"command": "query", "context": "production", "limit": 5}' | ruby ~/.agents/tools/vlogs/tool.rb
   ```

3. **Verify environment:**
   ```bash
   echo $VLOGS_SCRUB_KEY
   echo $KUBECONFIG
   kubectl config current-context
   ```
