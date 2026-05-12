# Telemetry Configuration

## Metrics Collection

The planner collects the following metrics:

### Performance Metrics

| Metric | Type | Description |
|--------|------|-------------|
| plans_created | counter | Total plans generated |
| tasks_delegated | counter | Subtasks handed off |
| planning_duration | histogram | Time from request to plan completion |
| decomposition_depth | histogram | Nesting levels in plans |

### Quality Metrics

| Metric | Type | Description |
|--------|------|-------------|
| dependency_accuracy | gauge | % of dependencies correctly identified |
| estimation_error | gauge | Difference between estimated and actual effort |
| risk_detection_rate | gauge | % of materialized risks that were identified |
| replanning_frequency | counter | Number of plans requiring revision |

### Operational Metrics

| Metric | Type | Description |
|--------|------|-------------|
| handoff_success_rate | gauge | % of delegations completing successfully |
| agent_utilization | gauge | Tasks per agent type |
| planning_queue_depth | gauge | Pending planning requests |

## Log Configuration

### Execution Traces

```yaml
traces:
  plan_creation:
    - timestamp
    - request_summary
    - decomposition_strategy
    - agent_selection_rationale
    - final_plan_hash
  
  delegation:
    - timestamp
    - task_id
    - target_agent
    - context_size
    - expected_outputs
  
  failure_analysis:
    - timestamp
    - plan_id
    - failure_point
    - root_cause
    - resolution_action
```

### Log Levels

- **DEBUG**: Detailed planning steps, working calculations
- **INFO**: Plan creation, delegation events, completions
- **WARN**: Replanning events, estimation deviations, slow operations
- **ERROR**: Failed plans, broken dependencies, handoff failures

## Retention Policy

```yaml
retention:
  traces: 30_days
  metrics: 90_days
  failures: 1_year
  performance_trends: persistent
```

## Privacy

- No user content in telemetry
- Task summaries only, not full descriptions
- Aggregate statistics only for sensitive metrics
- Opt-out capability for detailed traces
