---
name: create-agent
description: |
  Designs and scaffolds production-grade subagent configurations,
  prompts, workflows, permissions, routing contracts, evaluation
  harnesses, and operational constraints for multi-agent systems.

category: orchestration
version: 1.0.0

owner: platform
maturity: production

tags:
  - agents
  - orchestration
  - scaffolding
  - architecture
  - multi-agent
  - prompts
  - workflows

inputs:
  - agent_name
  - business_purpose
  - responsibilities
  - environment
  - available_tools
  - constraints
  - compliance_requirements
  - memory_requirements
  - handoff_targets

outputs:
  - directory_structure
  - agent_configuration
  - system_prompt
  - tool_permissions
  - routing_contracts
  - workflow_definitions
  - memory_strategy
  - evaluation_suite
  - operational_guidelines

tools_required:
  - filesystem
  - templating
  - validation

safety:
  - least_privilege
  - sandbox_execution
  - explicit_tool_permissions
  - human_approval_for_destructive_actions

success_criteria:
  - configuration_is_complete
  - prompts_are_modular
  - tools_are_constrained
  - handoffs_are_explicit
  - evaluation_is_defined
  - operational_boundaries_are_clear
---

# PURPOSE

The `create-agent` skill is responsible for generating comprehensive,
maintainable, and production-ready subagent configurations following
modern multi-agent architecture best practices.

The skill MUST optimize for:

1. Modularity
2. Maintainability
3. Security
4. Observability
5. Explicit operational boundaries
6. Reusability
7. Minimal prompt entropy
8. Clear delegation contracts
9. Deterministic orchestration
10. Scalable evaluation

The skill MUST avoid:
- monolithic prompts
- unrestricted tool access
- ambiguous responsibilities
- hidden routing behavior
- persistent uncontrolled memory
- excessive autonomy without safeguards

---

# INDUSTRY BEST PRACTICES

## 1. SINGLE RESPONSIBILITY PRINCIPLE

Each subagent SHOULD have:
- one primary role
- narrow operational scope
- explicit success criteria

GOOD:
- planner
- researcher
- reviewer
- tester
- deployer

BAD:
- "general-super-agent"
- mixed orchestration + execution + auditing

The narrower the responsibility:
- the lower the hallucination rate
- the easier the evaluation
- the safer the execution

---

## 2. EXPLICIT TOOL PERMISSIONS

Agents MUST NEVER inherit unrestricted tools.

Every subagent MUST define:
- allowed tools
- denied tools
- escalation requirements
- destructive action policy

Example:

```yaml
tools:
  allowed:
    - filesystem.read
    - git.diff
    - test.runner

  denied:
    - deployment.production
    - secrets.read

approval_required:
  - filesystem.delete
  - git.push
````

Best practices:

* default deny
* capability whitelisting
* approval gates
* environment isolation
* sandbox execution

---

## 3. MODULAR PROMPT ARCHITECTURE

System instructions SHOULD be decomposed.

Preferred structure:

```text
agent/
├── system.md
├── rules.md
├── style.md
├── constraints.md
└── examples/
```

Avoid:

* 2000-line system prompts
* duplicated instructions
* conflicting behavioral guidance

Benefits:

* maintainability
* composability
* lower token overhead
* isolated iteration

---

## 4. EXPLICIT HANDOFF CONTRACTS

Subagents MUST define:

* when to delegate
* who receives delegation
* expected input schema
* expected output schema

Example:

```yaml
handoffs:
  reviewer:
    when:
      - implementation_complete

    input:
      - diff
      - changed_files

    expected_output:
      - review_report
      - risk_assessment
```

Never rely on implicit delegation behavior.

---

## 5. STRUCTURED MEMORY STRATEGY

Agents MUST define:

* what is remembered
* retention policy
* summarization strategy
* privacy boundaries

Recommended memory layers:

```text
memory/
├── episodic/
├── semantic/
├── summaries/
└── scratchpads/
```

Best practices:

* avoid infinite context accumulation
* summarize aggressively
* separate temporary vs persistent memory
* isolate sensitive information

---

## 6. OBSERVABILITY + AUDITABILITY

Every production agent SHOULD support:

* execution logs
* decision traces
* tool invocation history
* prompt versioning
* evaluation reporting

Recommended:

```text
telemetry/
├── traces/
├── evaluations/
├── failures/
└── metrics/
```

Critical metrics:

* task success rate
* hallucination rate
* tool failure rate
* delegation frequency
* token consumption
* latency

---

## 7. CONFIGURATION OVER PROMPTING

Behavior SHOULD primarily live in:

* YAML
* JSON
* policy files
* workflow definitions

NOT:

* giant natural-language prompts

GOOD:

```yaml
retry_policy:
  max_attempts: 3
  exponential_backoff: true
```

BAD:

```text
"Try again a few times if something fails."
```

Structured configuration improves:

* determinism
* automation
* testing
* portability

---

## 8. SKILL-BASED CAPABILITY COMPOSITION

Agents SHOULD consume reusable skills.

Preferred:

```yaml
skills:
  - code-review
  - testing
  - git-operations
```

Avoid embedding workflows directly into:

* system prompts
* orchestration code
* agent identity

Benefits:

* reuse
* portability
* isolated testing
* easier upgrades

---

## 9. EVALUATION-FIRST DESIGN

Every agent MUST define:

* benchmarks
* test cases
* failure conditions
* expected outputs

Recommended:

```text
tests/
├── happy_path/
├── edge_cases/
├── adversarial/
└── regression/
```

Production agents without evaluation suites are incomplete.

---

## 10. HUMAN-IN-THE-LOOP SAFETY

Human approval SHOULD be required for:

* deployments
* production writes
* financial actions
* secret access
* destructive operations
* external communication

Example:

```yaml
human_approval_required:
  - production_deploy
  - database_migration
  - public_email_send
```

---

# RECOMMENDED DIRECTORY STRUCTURE

```text
~/.agents/
├── shared/
│   ├── prompts/
│   ├── policies/
│   ├── tools/
│   ├── schemas/
│   └── skills/
│
├── planner/
│   ├── agent.yaml
│   ├── system.md
│   ├── rules.md
│   ├── workflows/
│   ├── memory/
│   ├── tests/
│   └── telemetry/
│
├── coder/
├── reviewer/
├── tester/
└── deployer/
```

---

# REQUIRED AGENT CONFIGURATION FIELDS

Every subagent SHOULD define:

```yaml
name:
description:
role:
responsibilities:
success_criteria:
constraints:
skills:
tools:
memory:
handoffs:
evaluation:
safety:
telemetry:
runtime:
retry_policy:
timeouts:
human_approval_required:
```

---

# AGENT TEMPLATE

## Example `agent.yaml`

```yaml
name: reviewer

description: |
  Reviews code changes for correctness,
  maintainability, and security.

role: audit

responsibilities:
  - review_pull_requests
  - detect_security_issues
  - validate_style

success_criteria:
  - actionable_feedback
  - low_false_positive_rate

constraints:
  - never_modify_files
  - never_merge_code

skills:
  - code-review
  - security-analysis

tools:
  allowed:
    - filesystem.read
    - git.diff

memory:
  persistent: false
  session_summary: true

handoffs:
  planner:
    when:
      - review_complete

evaluation:
  benchmarks:
    - security_detection
    - style_accuracy

telemetry:
  enabled: true

runtime:
  model: current
  temperature: 0.1
  max_tokens: 8000
```

---

# PROMPT ENGINEERING STANDARDS

System prompts SHOULD:

* define role clearly
* define refusal boundaries
* define escalation conditions
* define output structure
* minimize verbosity
* avoid motivational prose

System prompts SHOULD NOT:

* contain business logic
* contain routing logic
* contain policy duplication
* contain hidden assumptions

---

# ROUTING BEST PRACTICES

Routers SHOULD:

* delegate deterministically
* use explicit capability matching
* avoid recursive delegation loops
* maintain execution graphs

Recommended routing dimensions:

* task type
* required tools
* risk level
* domain expertise
* context window requirements

---

# SECURITY BEST PRACTICES

Production agents SHOULD:

* run in sandboxes
* isolate credentials
* use ephemeral tokens
* avoid unrestricted shell access
* log sensitive operations
* support revocation

Agents MUST NEVER:

* expose secrets in prompts
* persist credentials in memory
* self-modify unrestricted policies
* bypass approval layers

---

# COMMON ANTI-PATTERNS

Avoid:

* mega-agents
* giant prompts
* unrestricted autonomy
* implicit memory accumulation
* hidden chain-of-thought persistence
* unclear ownership boundaries
* prompt-only configuration
* mixing orchestration with execution
* uncontrolled recursive delegation

---

# GOLD STANDARD MULTI-AGENT TOPOLOGY

```text
router
 ├── planner
 ├── researcher
 ├── coder
 ├── reviewer
 ├── tester
 └── deployer
```

Responsibilities:

* router → dispatch
* planner → decomposition
* researcher → retrieval
* coder → implementation
* reviewer → audit
* tester → validation
* deployer → controlled release

---

# FINAL VALIDATION CHECKLIST

Before finalizing an agent configuration, verify:

* [ ] Single clear responsibility
* [ ] Explicit permissions
* [ ] Explicit constraints
* [ ] Defined handoffs
* [ ] Structured memory policy
* [ ] Evaluation suite exists
* [ ] Human approval gates defined
* [ ] Observability enabled
* [ ] Prompt modularity enforced
* [ ] No unrestricted tool access
* [ ] Retry and timeout policies defined
* [ ] Failure escalation paths documented
* [ ] Skills are reusable
* [ ] Configuration is deterministic
* [ ] Secrets are isolated

```
```
