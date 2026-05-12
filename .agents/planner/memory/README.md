# Memory Configuration

## Session Memory

The planner maintains temporary context during active planning sessions.

### Active Plans
- Currently executing plans
- Pending subtasks
- Recent handoff statuses

### Working Memory
- Task analysis results
- Dependency mappings in progress
- Risk assessments under development

### Context Retention

```yaml
memory_layers:
  
  short_term:
    retention: session
    max_items: 5
    content:
      - current_plan
      - active_subtasks
      - recent_handoffs
      - pending_decisions
  
  medium_term:
    retention: 24h
    max_items: 20
    content:
      - completed_plans
      - delegation_history
      - risk_outcomes
      - estimation_accuracy
  
  long_term:
    retention: persistent
    max_items: 100
    content:
      - agent_capability_profiles
      - common_patterns
      - lessons_learned
      - planning_heuristics
```

### Summarization Strategy

When memory approaches limits:

1. **Compress completed plans** → Summary with key outcomes
2. **Archive delegation logs** → Counts and outcomes only
3. **Summarize risk assessments** → Which risks materialized
4. **Preserve agent performance** → Success rates by agent type

### Scratchpad Usage

Use scratchpad for:
- Drafting decomposition approaches
- Sketching dependency graphs
- Calculating effort estimates
- Recording assumption lists

Clear scratchpad at end of each planning session.

## Persistence Rules

```yaml
persistence:
  plan_documents: true
  execution_logs: true
  risk_outcomes: true
  
  ephemeral:
    - draft_decompositions
    - working_dependency_graphs
    - temporary_estimates
    - intermediate_calculations
```
