# Security Documentation

## Overview

This document describes the security model, threat considerations, and safe usage guidelines for the Trello tool.

## Threat Model

### Assets

- **Trello API Credentials**: API key and token with varying levels of board access
- **Board Data**: Cards, lists, comments, and member information
- **User Privacy**: Trello user data accessible via the API

### Trust Boundaries

```
┌─────────────────────────────────────────────────────────────┐
│                         User Agent                            │
│  ┌────────────────────────────────────────────────────────┐ │
│  │                    Trello Tool                          │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │           Trello API (api.trello.com)            │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Threats

#### 1. Credential Exposure

**Risk**: API keys or tokens leaked through logs, environment, or output.

**Mitigation**:
- Credentials passed only via environment variables
- Never logged or included in output
- Validated at startup before any network calls

#### 2. Input Injection

**Risk**: Malicious input (SQL injection, command injection, path traversal).

**Mitigation**:
- All IDs sanitized with strict regex: `^[a-zA-Z0-9_-]+$`
- Maximum length limits (64 characters for IDs)
- No filesystem or shell operations
- No user input concatenated into paths

#### 3. Data Exfiltration

**Risk**: Unauthorized access to board data via compromised credentials.

**Mitigation**:
- Tool respects Trello's native permissions
- No privilege escalation
- Read operations restricted to allowed scopes

#### 4. Destructive Operations

**Risk**: Accidental or malicious deletion of cards/boards.

**Mitigation**:
- `delete_card` marked as destructive in manifest
- Confirmation required policy in manifest
- Input validation prevents wildcard deletion

#### 5. Rate Limit Abuse

**Risk**: Excessive API calls causing rate limiting or denial of service.

**Mitigation**:
- Built-in retry logic with exponential backoff
- Timeout limits prevent runaway execution
- Agent-visible rate limit errors with retryable flag

## Permission Model

### Required Permissions

The tool requires these Trello API permissions:

| Operation | Required Token Scope |
|-----------|---------------------|
| `get_boards` | `read` |
| `get_board` | `read` |
| `get_lists` | `read` |
| `get_cards` | `read` |
| `get_card` | `read` |
| `create_card` | `write` |
| `update_card` | `write` |
| `move_card` | `write` |
| `delete_card` | `write` + user confirmation |
| `add_comment` | `write` |
| `get_members` | `read` |
| `search` | `read` |

### Network Permissions

```yaml
permissions:
  network:
    allow:
      - api.trello.com:443
    deny:
      - '*'
```

### Filesystem Permissions

```yaml
permissions:
  filesystem:
    read: []  # No filesystem read access
    write: [] # No filesystem write access
```

## Secret Handling

### Environment Variables

```bash
# Required
export TRELLO_API_KEY="your_api_key"
export TRELLO_API_TOKEN="your_api_token"
```

### Security Properties

1. **No Persistence**: Credentials never written to disk
2. **No Logging**: Credentials never appear in logs
3. **No Echo**: Credentials not returned in output
4. **No Serialization**: Credentials not included in state
5. **Validation**: Credentials validated before first use

### Input Override

Credentials can be passed per-request (not recommended for production):

```json
{
  "operation": "get_boards",
  "api_key": "key",
  "api_token": "token"
}
```

**Security Note**: Per-request credentials may appear in process listings or shell history. Environment variables are strongly preferred.

## Input Validation

### ID Sanitization

All Trello IDs (boards, lists, cards) are validated:

```ruby
def sanitize_id(id)
  # Only allow alphanumeric, underscore, hyphen
  sanitized = id.to_s.gsub(/[^a-zA-Z0-9_-]/, '')
  raise ValidationError if sanitized.empty? || sanitized.length > 64
  sanitized
end
```

### String Validation

| Field | Min Length | Max Length | Pattern |
|-------|-----------|------------|---------|
| `board_id` | 1 | 64 | `^[a-zA-Z0-9_-]+$` |
| `list_id` | 1 | 64 | `^[a-zA-Z0-9_-]+$` |
| `card_id` | 1 | 64 | `^[a-zA-Z0-9_-]+$` |
| `name` | 1 | 16,384 | Any |
| `desc` | 0 | - | Any |
| `text` | 1 | - | Any |
| `query` | 1 | 1,000 | Any |

### Parameter Validation

```yaml
safety:
  destructive: true
  confirmation_required:
    - delete_card
```

## Error Handling

### Secure Error Messages

Error messages reveal minimal information:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Card not found",
    "retryable": false
  }
}
```

**No exposure of**:
- Internal paths
- Stack traces
- Credential hints
- Backend details

### Error Codes

| Code | Information Disclosure |
|------|-------------------------|
| `AUTHENTICATION_ERROR` | Generic message, no credential details |
| `NOT_FOUND` | Resource type only, no ID in message |
| `VALIDATION_ERROR` | Field name only, no value exposure |
| `RATE_LIMIT_ERROR` | Generic message |
| `HTTP_ERROR` | Status code only, no response body |

## Transport Security

### HTTPS Only

- All API calls use TLS 1.2+
- Certificate validation enabled
- No fallback to HTTP

### Request Headers

```
Content-Type: application/json
```

No custom headers that could leak information.

## Safety Classifications

### Destructive Operations

| Operation | Destructive | Confirmation Required |
|-----------|-------------|----------------------|
| `get_boards` | No | No |
| `get_board` | No | No |
| `get_lists` | No | No |
| `get_cards` | No | No |
| `get_card` | No | No |
| `create_card` | No | No |
| `update_card` | No | No |
| `move_card` | No | No |
| `delete_card` | **Yes** | **Yes** |
| `add_comment` | No | No |
| `get_members` | No | No |
| `search` | No | No |

### Idempotent Operations

Read-only operations are idempotent and safe to retry:

- `get_boards`
- `get_board`
- `get_lists`
- `get_cards`
- `get_card`
- `get_members`
- `search`

## Audit and Observability

### Structured Logging

```json
{
  "level": "info",
  "event": "tool_execution",
  "tool": "trello",
  "operation": "get_boards",
  "duration_ms": 523,
  "success": true
}
```

**No logging of**:
- Credentials
- Full request/response bodies
- Sensitive card content

### Metrics

Collected metrics (no PII):
- Request count by operation
- Error count by error code
- Latency percentiles
- Retry count

## Secure Usage Guidelines

### For Agent Developers

1. **Credential Management**
   - Use environment variables, never hardcode
   - Rotate tokens regularly
   - Use least-privilege tokens

2. **Input Handling**
   - Validate IDs before passing to tool
   - Sanitize user-provided content
   - Handle errors gracefully

3. **Destructive Operations**
   - Always confirm `delete_card` with user
   - Implement undo where possible
   - Log all destructive actions

4. **Rate Limiting**
   - Respect `retryable: true` errors
   - Implement exponential backoff
   - Cache read results when appropriate

### For Administrators

1. **Environment Setup**
   ```bash
   # Secure permissions on env files
   chmod 600 ~/.trello_credentials

   # Source securely
   source ~/.trello_credentials
   ```

2. **Token Scope**
   - Use read-only tokens for read-only use cases
   - Create separate tokens per agent/team
   - Revoke compromised tokens immediately

3. **Monitoring**
   - Monitor API usage in Trello admin panel
   - Set up alerts for rate limit errors
   - Review access logs regularly

## Incident Response

### Credential Compromise

1. Revoke token immediately in Trello settings
2. Generate new token
3. Update environment variables
4. Review API access logs for unauthorized activity

### Suspicious Activity

1. Check Trello audit logs
2. Review agent operation history
3. Validate all recent card/board modifications
4. Consider temporary token suspension

## Security Updates

This section tracks security-related changes:

### 1.0.0
- Initial security review
- Implemented input sanitization
- Added error code obfuscation
- Defined confirmation policies

## Compliance

### Data Handling

- No persistent storage of Trello data
- No transmission to third parties
- Respects Trello's data retention policies

### Regulations

- GDPR: User data handled per Trello's DPA
- SOC 2: Tool design supports audit requirements
- CCPA: No sale of personal information

## Contact

For security issues:
- Do not open public issues for security vulnerabilities
- Contact: security@example.com (placeholder)
- Response time: 24 hours

## References

- [Trello API Terms of Service](https://trello.com/legal/terms)
- [Trello API Documentation](https://developer.atlassian.com/cloud/trello/)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
