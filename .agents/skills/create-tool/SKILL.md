---
name: create-tool
description: >-
  Create Agent tool. Use when authoring a new tool or asking about agent tools.
---

# Skill: create-tool

## Purpose

The `create-tool` skill is responsible for designing, scaffolding, validating, and documenting high-quality subagent tools that can be safely and reliably used by autonomous or semi-autonomous AI agents.

This skill produces:
- executable tools
- manifests/configuration
- schemas
- capability metadata
- permission boundaries
- runtime contracts
- validation rules
- observability hooks
- documentation
- tests

The goal is to create production-grade agent tools that are:
- deterministic
- composable
- observable
- secure
- self-documenting
- machine-readable
- human-maintainable

---

# Core Principles

## 1. Explicit Contracts Over Implicit Behavior

Every tool MUST define:
- inputs
- outputs
- side effects
- failure modes
- permissions
- runtime dependencies
- timeout behavior
- retry semantics

Avoid hidden assumptions.

---

## 2. Machine-Readable First

All configuration should prioritize structured schemas over prose.

Preferred formats:
- JSON Schema
- YAML
- TOML
- OpenAPI
- MCP-compatible manifests

Human documentation supplements structured metadata.

---

## 3. Deterministic Behavior

Tools should:
- minimize nondeterminism
- avoid ambiguous outputs
- return stable formats
- support idempotency where possible

Avoid:
- freeform stdout without structure
- random formatting changes
- hidden environment dependencies

---

## 4. Least Privilege

Every tool MUST request the minimum permissions required.

Examples:
- filesystem scope restrictions
- network allowlists
- sandboxing
- read-only vs write permissions
- command execution constraints

Never default to unrestricted execution.

---

## 5. Fail Loudly and Transparently

Tools should:
- return actionable errors
- include machine-readable error codes
- expose retryability
- distinguish user errors from system errors

Bad:
```json
{ "error": "failed" }
````

Good:

```json
{
  "error": {
    "code": "FILE_NOT_FOUND",
    "message": "Target config file does not exist",
    "retryable": false
  }
}
```

---

# Recommended Tool Structure

```text
tool-name/
├── tool.rb
├── manifest.yaml
├── schema/
│   ├── input.schema.json
│   └── output.schema.json
├── prompts/
├── tests/
├── examples/
├── README.md
└── SECURITY.md
```

---

# Required Manifest Fields

Every tool SHOULD include a manifest.

## Minimum Recommended Fields

```yaml
name: search_docs
description: Semantic search over internal documentation
version: 1.2.0

entrypoint:
  type: ruby
  command: ruby tool.rb

capabilities:
  - search
  - retrieval

input_schema: schema/input.schema.json
output_schema: schema/output.schema.json

permissions:
  filesystem:
    read:
      - ~/docs
  network: false

timeouts:
  execution_seconds: 30

retries:
  max_attempts: 2

observability:
  structured_logs: true
  tracing: true

safety:
  destructive: false
  requires_confirmation: false
```

---

# Input Schema Best Practices

Inputs SHOULD:

* validate early
* enforce types
* constrain ranges
* define defaults explicitly
* reject unknown fields

Example:

```json
{
  "type": "object",
  "properties": {
    "query": {
      "type": "string",
      "minLength": 3,
      "maxLength": 500
    },
    "limit": {
      "type": "integer",
      "minimum": 1,
      "maximum": 50,
      "default": 10
    }
  },
  "required": ["query"],
  "additionalProperties": false
}
```

---

# Output Design Best Practices

Outputs SHOULD:

* be stable
* be structured
* include metadata
* support downstream automation

Preferred:

```json
{
  "results": [],
  "count": 0,
  "execution_ms": 42
}
```

Avoid:

```text
Found some stuff maybe related to your query
```

---

# Tool Categories

## Stateless Tools

Preferred default.

Characteristics:

* deterministic
* no persistent memory
* pure transformations

Examples:

* parsers
* converters
* validators

---

## Stateful Tools

Require explicit lifecycle handling.

Must define:

* storage location
* concurrency model
* persistence strategy
* cleanup behavior

Examples:

* vector stores
* memory systems
* task queues

---

## Side-Effecting Tools

Require elevated safeguards.

Examples:

* deployment tools
* filesystem mutation
* payment APIs
* infrastructure provisioning

Must include:

* confirmation policies
* dry-run mode
* rollback strategy
* audit logging

---

# Security Requirements

## Mandatory

Every tool MUST:

* sanitize inputs
* validate paths
* avoid shell injection
* constrain subprocess execution
* handle secrets securely
* avoid leaking credentials in logs

---

## Recommended

Prefer:

* parameterized execution
* sandboxing
* capability isolation
* ephemeral credentials
* environment variable allowlists

---

# Observability Standards

Every production-grade tool SHOULD expose:

## Structured Logs

Example:

```json
{
  "level": "info",
  "event": "tool_execution",
  "tool": "search_docs",
  "duration_ms": 52
}
```

---

## Metrics

Recommended:

* execution count
* failure count
* timeout count
* retry count
* latency
* token usage
* cache hit rate

---

## Tracing

Support:

* request IDs
* correlation IDs
* execution spans

---

# Agent Compatibility

Tools SHOULD be:

* self-describing
* discoverable
* composable
* interruption-safe

Recommended compatibility targets:

* MCP
* OpenAPI
* JSON-RPC
* LangChain Tools
* OpenAI tool calling
* Claude tool use
* AutoGen
* CrewAI

---

# Confirmation Policies

Destructive actions MUST define explicit confirmation behavior.

Example:

```yaml
safety:
  destructive: true
  confirmation_required:
    - delete
    - overwrite
    - deploy
```

---

# Timeout and Retry Strategy

Every tool SHOULD define:

* max execution time
* retry policy
* backoff strategy
* cancellation behavior

Example:

```yaml
timeouts:
  execution_seconds: 60

retries:
  max_attempts: 3
  backoff: exponential
```

---

# Tool Documentation Requirements

Each tool SHOULD include:

## README.md

Must contain:

* purpose
* usage
* examples
* configuration
* permissions
* limitations
* failure cases

---

## SECURITY.md

Must contain:

* threat model
* permission model
* secret handling
* known risks
* escalation paths

---

# Testing Standards

Minimum recommended coverage:

* schema validation
* happy path
* edge cases
* malformed inputs
* permission failures
* timeout handling
* retry behavior

Recommended test categories:

* unit tests
* integration tests
* contract tests
* sandbox tests
* regression tests

---

# Versioning

Use semantic versioning.

Rules:

* breaking changes → major
* new functionality → minor
* fixes → patch

Example:

```text
2.4.1
```

---

# Recommended Metadata Extensions

```yaml
tags:
  - retrieval
  - filesystem

maintainers:
  - platform-team

maturity: production

supports_streaming: false

supports_parallel_calls: true

cost_estimate:
  cpu: low
  memory: medium
  network: none
```

---

# Anti-Patterns

Avoid:

* hidden prompts
* implicit side effects
* unrestricted shell execution
* mutable global state
* undocumented environment variables
* freeform outputs
* silent retries
* opaque failures
* overbroad permissions

---

# Gold Standard Tool Checklist

A production-grade subagent tool SHOULD:

* [ ] Have a manifest
* [ ] Define input/output schemas
* [ ] Validate all inputs
* [ ] Produce structured outputs
* [ ] Define permissions
* [ ] Support timeouts
* [ ] Support retries
* [ ] Emit structured logs
* [ ] Include tests
* [ ] Include examples
* [ ] Include security documentation
* [ ] Support observability
* [ ] Be deterministic where possible
* [ ] Fail transparently
* [ ] Minimize side effects
* [ ] Be safe for autonomous execution

---

# Preferred Design Philosophy

The best agent tools behave like reliable infrastructure APIs:

* predictable
* typed
* observable
* composable
* permissioned
* resilient

Agent tools should optimize for:

1. machine operability
2. safety
3. maintainability
4. human readability

not merely convenience for the original author.
