# VictoriaLogs Tool - Usage Guide

## Quick Start

### 1. Setup (One-time)

Add the tool to your PATH:

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="/Users/gard/Developer/sh/dot-agents/.agents/tools/vlogs:$PATH"

# Or create an alias
alias vlogs="/Users/gard/Developer/sh/dot-agents/.agents/tools/vlogs/vlogs"
```

### 2. Set Your Scrub Key (Required)

The tool requires a secret key for PII scrubbing (unless using `--raw`):

```bash
# Add to your shell profile
export VLOGS_SCRUB_KEY="your-secret-key-here"

# Or set for current session only
export VLOGS_SCRUB_KEY=$(openssl rand -hex 32)
```

### 3. Test It

```bash
# Check if it's working
vlogs --help

# Test with your Kubernetes context
vlogs query -c your-k8s-context
```

---

## Commands

### **query** - Search Logs

Search and filter log entries.

```bash
# Basic query - last hour
vlogs query -c production

# Search for errors only
vlogs query -c production --query "level:ERROR"

# Last 30 minutes, limit to 20 results
vlogs query -c production --query "level:ERROR" --start 30m --limit 20

# Search for specific application
vlogs query -c production --query "application:make-api"

# JSON output (for scripting)
vlogs query -c production --format json

# Raw output (no PII scrubbing - shows real data)
vlogs query -c production --raw
```

**Example Output:**
```
16:00:00  ERROR  api  ApiController  Database error for user [EMAIL:7c5f7656]
16:01:00  INFO   web  HomeController  Request processed successfully
16:02:00  WARN   api  AuthController   Slow response | POST /api/login | 200 | db=1500.5ms
```

---

### **stats** - Aggregation Queries

Run statistical aggregations on your logs.

```bash
# Count by log level
vlogs stats -c production --query "stats count(*) by (level)"

# Count by application
vlogs stats -c production --query "stats count(*) by (application)"

# Average response time by path
vlogs stats -c production --query "stats avg(duration_ms) by (payload.path)"

# JSON output
vlogs stats -c production --query "stats count(*) by (level)" --format json
```

**Example Output:**
```
level                                        count
--------------------------------------------------
INFO                                          1250  
WARN                                           120  
ERROR                                           45  
```

---

### **fields** - List Available Fields

See what fields are available in your logs.

```bash
# List all fields
vlogs fields -c production

# List fields in a specific application
vlogs fields -c production --query "application:make-api"
```

**Example Output:**
```
level                                              10000 hits
application                                        10000 hits
message                                             9500 hits
_time                                              10000 hits
```

---

### **values** - List Field Values

See unique values for a specific field.

```bash
# List all log levels
vlogs values -c production --field level

# List all applications
vlogs values -c production --field application

# List status codes
vlogs values -c production --field payload.status
```

**Example Output:**
```
ERROR                                               45 hits
INFO                                              1250 hits
WARN                                               120 hits
DEBUG                                                5 hits
```

---

### **hits** - Log Volume Over Time

See how many logs were generated over time.

```bash
# Overall log volume (last hour)
vlogs hits -c production

# Volume by log level
vlogs hits -c production --field level

# Volume for last 24 hours
vlogs hits -c production --field level --start 24h
```

**Example Output (JSON):**
```json
{
  "timestamps": ["2026-05-13T14:00:00Z", "2026-05-13T15:00:00Z"],
  "values": [1500, 2100],
  "total": 3600
}
```

---

### **cleanup** - Kill Port-Forward

Stop the background port-forward process.

```bash
vlogs cleanup
```

---

## Common Use Cases

### **1. Debug Recent Errors**

```bash
# Get recent errors
vlogs query -c production --query "level:ERROR" --start 30m

# Get errors with stack traces
vlogs query -c production --query "level:ERROR AND exception.message:*" --start 1h
```

### **2. Check Application Health**

```bash
# Error count by application
vlogs stats -c production --query "stats count(*) by (application)" --start 1h

# HTTP status codes
vlogs values -c production --field payload.status --start 1h
```

### **3. Performance Analysis**

```bash
# Slow requests
vlogs query -c production --query "duration_ms:>1000" --start 1h

# Average response time by endpoint
vlogs stats -c production --query "stats avg(duration_ms) by (payload.path)" --start 1h
```

### **4. Request Tracing**

```bash
# Find specific request ID
vlogs query -c production --query "named_tags.request_id:abc123"
```

---

## Query Syntax (LogsQL)

VictoriaLogs uses LogsQL. Here are common patterns:

| Query | Description |
|-------|-------------|
| `*` | All logs |
| `level:ERROR` | Error level logs |
| `level:ERROR AND application:make-api` | Errors from specific app |
| `message:"database connection"` | Logs containing phrase |
| `payload.status:500` | HTTP 500 errors |
| `duration_ms:>1000` | Duration > 1000ms |
| `_time:2026-05-13` | Specific date |
| `stats count(*) by (level)` | Count by level |
| `stats avg(duration_ms)` | Average duration |

---

## Tips & Tricks

### **1. Pipe to Other Tools**

```bash
# Count lines
vlogs query -c production | wc -l

# Filter with grep
vlogs query -c production | grep "specific-error"

# Save to file
vlogs query -c production > logs.json
```

### **2. Use with jq**

```bash
# Extract specific fields (JSON mode)
vlogs query -c production --format json | jq '.level, .message'

# Pretty print
vlogs query -c production --format json | jq .
```

### **3. Common Aliases**

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
# Quick error checking
alias vlogs-errors="vlogs query -c production --query 'level:ERROR' --start 30m"

# Production context shortcut
alias vlogs-prod="vlogs -c production"

# Staging context shortcut  
alias vlogs-staging="vlogs -c staging"
```

### **4. Auto-Detect Context**

If you don't specify `-c`, the tool will use your current kubectl context:

```bash
# Set your kubectl context
kubectl config use-context production

# Query without specifying context
vlogs query
```

---

## Troubleshooting

### **"VLOGS_SCRUB_KEY is not set"**

```bash
# Set the environment variable
export VLOGS_SCRUB_KEY="your-secret-key"

# Or use --raw (caution: exposes real customer data)
vlogs query -c production --raw
```

### **"Port-forward failed to start"**

```bash
# Check if something is already using port 9428
lsof -ti:9428

# Kill any existing port-forwards
vlogs cleanup

# Try again
vlogs query -c production
```

### **"Cannot connect to VictoriaLogs"**

```bash
# Check if VictoriaLogs service exists
kubectl --context your-context get svc -n monitoring | grep victoria-logs

# Verify service name in your cluster
kubectl --context your-context get svc -n monitoring
```

### **"Unknown command"**

Make sure you're using one of the valid commands:
- `query`
- `stats`
- `fields`
- `values`
- `hits`
- `cleanup`

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `VLOGS_SCRUB_KEY` | Yes* | Secret key for PII scrubbing |
| `KUBECONFIG` | No | Path to kubeconfig file |

*Not required if using `--raw` flag

---

## Files Location

```
/Users/gard/Developer/sh/dot-agents/.agents/tools/vlogs/
├── vlogs              # Main wrapper script (use this)
├── tool.rb            # Core tool implementation
├── manifest.yaml      # Tool configuration
├── README.md          # Documentation
├── USAGE.md           # This file
└── schema/
    ├── input.schema.json
    └── output.schema.json
```

---

## Need Help?

```bash
# Show help
vlogs --help

# Check tool status
cd /Users/gard/Developer/sh/dot-agents/.agents/tools/vlogs && ruby -c tool.rb && echo "Tool OK"
```
