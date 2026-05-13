# VictoriaLogs Tool

Query and analyze logs from VictoriaLogs instances running in Kubernetes clusters.

## Overview

This tool provides a secure interface to query VictoriaLogs with automatic PII scrubbing. It manages Kubernetes port-forwarding automatically and supports multiple output formats.

## Features

- **Automatic Port-Forwarding**: Manages kubectl port-forward to VictoriaLogs service
- **PII Scrubbing**: HMAC-based tokenization of sensitive data (emails, names, phone numbers, etc.)
- **Multiple Output Formats**: JSON for scripting, table for human readability
- **LogSQL Queries**: Full support for VictoriaLogs query language
- **Time Range Support**: Relative (5m, 1h, 24h) and absolute timestamps
- **Field Exploration**: List available fields and their values
- **Statistics**: Run aggregation queries with formatted output

## Commands

### `query`
Search log entries matching a query.

```bash
vlogs query --context production --query "application:make-api level:ERROR"
```

**Options:**
- `--query`: LogsQL query string (default: `*`)
- `--start`: Start time - relative (5m, 1h, 24h) or absolute (2026-03-25T08:00:00Z)
- `--end`: End time (default: now)
- `--limit`: Maximum results (default: 50)
- `--format`: Output format - `json` or `table` (default: `json`)
- `--raw`: Disable PII scrubbing (requires VLOGS_SCRUB_KEY to be unset)

### `stats`
Run aggregation/stats queries.

```bash
vlogs stats --context production --query 'stats count(*) by (level)'
```

**Options:** Same as `query`, plus aggregation functions in the query string.

### `fields`
List available field names.

```bash
vlogs fields --context production --query "level:ERROR"
```

**Options:** Same as `query`.

### `values`
List unique values for a specific field.

```bash
vlogs values --context production --field "level" --query "application:make-api"
```

**Options:**
- `--field`: Required. Field name to get values for
- Other options same as `query`

### `hits`
Show log volume over time.

```bash
vlogs hits --context production --field "level" --start "24h"
```

**Options:**
- `--field`: Optional. Group by this field
- Other options same as `query`

### `cleanup`
Kill active port-forward.

```bash
vlogs cleanup
```

## Configuration

### Environment Variables

- `VLOGS_SCRUB_KEY`: Secret key for PII hashing. Required unless using `--raw`.
- `KUBECONFIG`: Path to Kubernetes config file (optional, uses default if not set)

### PII Scrubbing

By default, all output is scrubbed for PII. The following patterns are detected and tokenized:

- Names (first, last, full, display, user, customer, etc.)
- Email addresses
- Phone numbers
- Street addresses, city, zip/postal codes
- SSN
- Date of birth

Token format: `[TYPE:HASH]` where HASH is first 8 characters of HMAC-SHA256.

### Port-Forward Management

The tool automatically:
1. Checks for existing port-forward in `/tmp/vlogs-portforward.pid`
2. Starts new port-forward if needed
3. Reuses existing port-forward if context matches
4. Kills conflicting port-forwards on different contexts

## Usage Examples

### Query recent errors
```bash
vlogs query --context production --query "level:ERROR" --start "1h" --format table
```

### Stats by application
```bash
vlogs stats --context production --query 'stats count(*) by (application)' --format table
```

### Find all available levels
```bash
vlogs values --context production --field "level"
```

### Web request logs with details
```bash
vlogs query --context production --query "payload.method:*" --start "30m" --format table
```

### Raw output for debugging
```bash
vlogs query --context production --query "_time:2026-05-10" --limit 10 --raw
```

## Architecture

```
User Input → Port-Forward Check → K8s API → VictoriaLogs API
                                    ↓
                              PII Scrubbing
                                    ↓
                            Format Output → Return
```

## Safety

- Port-forward only binds to localhost (127.0.0.1)
- PII scrubbing is mandatory by default
- HMAC secret never leaves the environment
- PID file ensures only one port-forward per context

## Troubleshooting

**"Port-forward failed to start"**
- Check if port 9428 is already in use: `lsof -ti:9428`
- Run `vlogs cleanup` to kill orphaned processes

**"Cannot connect to VictoriaLogs"**
- Verify the port-forward is running
- Check that the VictoriaLogs service exists in the monitoring namespace
- Verify Kubernetes context is correct

**"VLOGS_SCRUB_KEY is not set"**
- Either set the environment variable or use `--raw` flag
- Using `--raw` will output raw customer data - use with caution

## License

Part of the dot-agents tool suite.
