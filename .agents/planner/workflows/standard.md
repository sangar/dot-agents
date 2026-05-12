# Planner Workflows

## Standard Planning Workflow

This is the default workflow for task decomposition and delegation.

### Workflow: Standard Plan Creation

```yaml
workflow:
  name: standard_plan_creation
  
  steps:
    1_analyze:
      action: analyze_request
      description: Understand the full scope of the task
      inputs:
        - user_request
        - context_files (optional)
      outputs:
        - task_analysis
      criteria: Requirements are clear and scope is defined
    
    2_decompose:
      action: break_down_task
      description: Create subtasks with single responsibilities
      inputs:
        - task_analysis
      outputs:
        - subtask_list
      criteria: All aspects of task covered, no overlap between subtasks
    
    3_map_dependencies:
      action: identify_dependencies
      description: Determine execution order and relationships
      inputs:
        - subtask_list
      outputs:
        - dependency_graph
      criteria: All prerequisites identified, no circular dependencies
    
    4_assess_risks:
      action: evaluate_risks
      description: Identify and mitigate potential issues
      inputs:
        - subtask_list
        - dependency_graph
      outputs:
        - risk_assessment
      criteria: Every high-impact risk has mitigation strategy
    
    5_assign_agents:
      action: match_capabilities
      description: Route subtasks to appropriate agents
      inputs:
        - subtask_list
        - dependency_graph
        - agent_capabilities
      outputs:
        - delegation_plan
      criteria: Each subtask matches agent capability profile
    
    6_define_milestones:
      action: establish_checkpoints
      description: Create measurable progress indicators
      inputs:
        - delegation_plan
      outputs:
        - milestone_definitions
      criteria: Clear checkpoints for progress tracking
    
    7_create_plan_document:
      action: generate_plan_yaml
      description: Produce structured plan output
      inputs:
        - task_analysis
        - subtask_list
        - dependency_graph
        - risk_assessment
        - delegation_plan
        - milestone_definitions
      outputs:
        - plan_document
      criteria: Valid YAML format, all required fields present
    
    8_handoff:
      action: delegate_tasks
      description: Initiate execution through agent handoffs
      inputs:
        - plan_document
      outputs:
        - delegation_confirmations
      criteria: All ready subtasks delegated to appropriate agents
```

## Specialized Workflows

### Workflow: Complex Multi-Phase Planning

For large initiatives requiring multiple planning sessions.

```yaml
workflow:
  name: multi_phase_planning
  
  context:
    trigger: Task exceeds 20 subtasks or spans multiple domains
    
  phases:
    discovery:
      - gather_requirements
      - identify_stakeholders
      - define_constraints
      - establish_boundaries
      
    architecture:
      - design_high_level_structure
      - identify_major_components
      - define_interfaces
      - sequence_major_phases
      
    detailed_planning:
      - plan_phase_1
      - plan_phase_2
      - plan_phase_n
      - integrate_phases
      
    validation:
      - review_completeness
      - check_dependencies_across_phases
      - validate_resource_allocation
      - finalize_timeline
```

### Workflow: Research-Driven Planning

For tasks requiring investigation before planning.

```yaml
workflow:
  name: research_driven_planning
  
  context:
    trigger: Unknown domain, unclear implementation approach, or missing information
    
  steps:
    1_formulate_questions:
      action: identify_knowledge_gaps
      description: Determine what information is needed
      
    2_delegate_research:
      action: handoff_to_researcher
      agent: researcher
      description: Gather necessary information
      
    3_await_findings:
      action: receive_research_report
      description: Incorporate research results
      
    4_create_informed_plan:
      action: execute_standard_planning
      description: Create plan with research insights
```

### Workflow: Iterative Planning

For tasks requiring adaptive planning based on feedback.

```yaml
workflow:
  name: iterative_planning
  
  context:
    trigger: Dynamic requirements, experimental work, or unclear scope
    
  cycle:
    - create_initial_plan
    - delegate_first_phase
    - review_results
    - adjust_plan
    - continue_or_complete
    
  exit_conditions:
    - plan_complete
    - scope_clarified
    - objectives_achieved
```

### Workflow: Risk-First Planning

For high-stakes or sensitive operations.

```yaml
workflow:
  name: risk_first_planning
  
  context:
    trigger: Production changes, destructive operations, or security-sensitive work
    
  steps:
    1_comprehensive_risk_analysis:
      action: deep_risk_assessment
      description: Exhaustive risk identification and analysis
      
    2_mitigation_planning:
      action: design_mitigations
      description: Develop comprehensive risk mitigation strategies
      
    3_rollback_design:
      action: create_rollback_procedures
      description: Design and document rollback procedures
      
    4_guardrail_definition:
      action: establish_guardrails
      description: Define automated and manual safety checks
      
    5_human_approval:
      action: request_approval
      description: Obtain authorization for high-risk elements
      
    6_execute_with_monitoring:
      action: monitored_execution
      description: Execute plan with enhanced monitoring
```

## Handoff Workflows

### Workflow: Delegation Sequence

```yaml
workflow:
  name: delegation_sequence
  
  steps:
    1_identify_ready_tasks:
      action: find_unblocked_tasks
      description: Locate tasks with all dependencies satisfied
      
    2_prepare_context:
      action: gather_task_context
      description: Collect all relevant information for handoff
      
    3_select_agent:
      action: choose_target_agent
      description: Match task to agent capabilities
      
    4_create_handoff_spec:
      action: generate_handoff_package
      description: Create complete handoff specification
      
    5_execute_handoff:
      action: delegate_to_agent
      description: Transfer control to selected agent
      
    6_monitor_completion:
      action: track_task_progress
      description: Monitor for completion or failure
      
    7_handle_results:
      action: process_completion
      description: Integrate results and trigger next phase
```

### Workflow: Failure Recovery

```yaml
workflow:
  name: failure_recovery
  
  trigger: Delegated task fails or returns incomplete
  
  steps:
    1_analyze_failure:
      action: diagnose_issue
      description: Understand why the task failed
      
    2_assess_options:
      action: evaluate_alternatives
      description: Determine if retry, replan, or escalate
      
    3_decide_path:
      action: choose_recovery_action
      branches:
        retry:
          condition: Transient failure, same approach valid
          action: re_delegate_with_adjustments
        replan:
          condition: Approach flawed, new strategy needed
          action: create_revised_plan
        escalate:
          condition: Beyond system capability or authority
          action: request_human_intervention
        abort:
          condition: Task impossible or not worth cost
          action: terminate_with_explanation
```
