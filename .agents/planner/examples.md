# Planner Examples

## Example 1: Simple Task Decomposition

**Input**: "Add a new feature to log user authentication events"

**Output Plan**:

```yaml
plan:
  objective: Implement user authentication event logging
  
  context:
    background: Application needs to track user login/logout for security auditing
    constraints:
      - Must not impact login performance
      - Must comply with data retention policy (90 days)
    assumptions:
      - Existing auth system is in place
      - Log storage infrastructure exists
  
  phases:
    - name: Design
      description: Define logging schema and integration points
      subtasks:
        - id: auth-log-design
          description: Design event schema for authentication events
          agent: researcher
          inputs:
            - current_auth_system_docs
            - logging_requirements
          outputs:
            - event_schema_definition
            - integration_specification
          success_criteria:
            - Schema captures user_id, timestamp, event_type, ip_address
            - Integration approach documented with no performance impact
          dependencies: []
          estimated_effort: small
          risks:
            - Performance degradation if logging is synchronous
    
    - name: Implementation
      description: Add logging to authentication flow
      subtasks:
        - id: auth-log-impl
          description: Implement logging calls in authentication handlers
          agent: coder
          inputs:
            - event_schema_definition
            - integration_specification
            - codebase_access
          outputs:
            - modified_auth_files
            - unit_tests
          success_criteria:
            - Login events logged correctly
            - Logout events logged correctly
            - Failed auth attempts logged
            - Unit tests pass
          dependencies: [auth-log-design]
          estimated_effort: medium
          risks:
            - Breaking existing auth flow
    
    - name: Validation
      description: Verify logging works correctly
      subtasks:
        - id: auth-log-test
          description: Create and run integration tests
          agent: tester
          inputs:
            - implementation_complete
            - test_requirements
          outputs:
            - test_report
            - performance_metrics
          success_criteria:
            - All auth scenarios covered by tests
            - Performance impact < 10ms per request
          dependencies: [auth-log-impl]
          estimated_effort: small
          risks:
            - Log storage capacity exceeded
  
  risks:
    - description: Synchronous logging causes login delays
      likelihood: medium
      impact: high
      mitigation: Implement async logging queue
    
    - description: Log volume exceeds storage capacity
      likelihood: low
      impact: medium
      mitigation: Configure log rotation and 90-day retention policy
  
  timeline:
    estimated_duration: 2-3 days
    critical_path: [auth-log-design, auth-log-impl, auth-log-test]
    milestones:
      - name: Design Complete
        criteria: Schema approved and integration spec documented
      - name: Implementation Complete
        criteria: Code changes merged and unit tests passing
      - name: Validation Complete
        criteria: Integration tests pass, performance acceptable
  
  rollback_strategy:
    conditions:
      - Performance degradation > 50ms per request
      - Auth flow breakage detected
      - Log corruption observed
    steps:
      - Revert auth handler changes
      - Disable logging configuration
      - Verify auth flow restoration
    verification:
      - Login/logout functionality tested
      - Performance metrics baseline restored
```

## Example 2: Complex Multi-Phase Plan

**Input**: "Migrate database from PostgreSQL 12 to PostgreSQL 15 with zero downtime"

**Output Plan**:

```yaml
plan:
  objective: Zero-downtime migration from PostgreSQL 12 to PostgreSQL 15
  
  context:
    background: Database upgrade required for new features and security patches
    constraints:
      - Zero downtime requirement
      - Data integrity must be preserved
      - Rollback capability required
    assumptions:
      - Read replicas available
      - Application supports connection switching
      - Maintenance window available for final cutover
  
  phases:
    - name: Preparation
      description: Set up infrastructure and validate approach
      subtasks:
        - id: pg-migrate-research
          description: Research PostgreSQL 12→15 breaking changes
          agent: researcher
          outputs: [breaking_changes_report, migration_guide]
          success_criteria: All breaking changes identified and mitigation documented
          estimated_effort: medium
        
        - id: pg-migrate-replica
          description: Create PostgreSQL 15 replica environment
          agent: deployer
          inputs: [breaking_changes_report]
          outputs: [replica_environment_ready]
          success_criteria: PG15 replica running with same schema
          dependencies: [pg-migrate-research]
          estimated_effort: medium
          risks:
            - Schema compatibility issues
        
        - id: pg-migrate-validation
          description: Validate application compatibility with PG15
          agent: tester
          inputs: [replica_environment_ready]
          outputs: [compatibility_report]
          success_criteria: All test suites pass against PG15 replica
          dependencies: [pg-migrate-replica]
          estimated_effort: large
    
    - name: Migration
      description: Execute data synchronization and cutover
      subtasks:
        - id: pg-migrate-sync
          description: Set up logical replication to PG15
          agent: deployer
          inputs: [replica_environment_ready, compatibility_report]
          outputs: [replication_active, sync_verified]
          success_criteria: Real-time replication lag < 1 second
          dependencies: [pg-migrate-validation]
          estimated_effort: medium
          risks:
            - Replication lag unacceptable
            - Data drift between versions
        
        - id: pg-migrate-cutover
          description: Execute cutover to PostgreSQL 15
          agent: deployer
          inputs: [sync_verified]
          outputs: [cutover_complete, old_decommissioned]
          success_criteria: Production traffic on PG15, PG12 decommissioned
          dependencies: [pg-migrate-sync]
          estimated_effort: small
          risks:
            - Cutover failure requiring rollback
  
  risks:
    - description: Breaking change causes application failure
      likelihood: medium
      impact: high
      mitigation: Thorough compatibility testing in replica environment
    
    - description: Replication lag causes data inconsistency
      likelihood: medium
      impact: high
      mitigation: Monitor lag continuously, pause writes if lag > threshold
    
    - description: Cutover rollback needed
      likelihood: low
      impact: high
      mitigation: Maintain PG12 read replica for 48 hours post-cutover
  
  timeline:
    estimated_duration: 1-2 weeks
    critical_path: [pg-migrate-research, pg-migrate-replica, pg-migrate-validation, pg-migrate-sync, pg-migrate-cutover]
    milestones:
      - name: Research Complete
        criteria: Breaking changes understood, approach validated
      - name: Infrastructure Ready
        criteria: PG15 replica environment provisioned and tested
      - name: Compatibility Verified
        criteria: Application passes all tests against PG15
      - name: Synchronization Active
        criteria: Real-time replication operational
      - name: Migration Complete
        criteria: Production on PG15, rollback window closed
  
  rollback_strategy:
    conditions:
      - Application errors post-cutover
      - Performance degradation > 20%
      - Data integrity issues detected
    steps:
      - Redirect traffic to PG12 (read-only if necessary)
      - Restore PG12 write capability
      - Analyze and fix issues
      - Schedule retry migration
    verification:
      - Application functionality restored
      - Performance metrics baseline restored
      - Data consistency verified
```

## Example 3: Risk-First Planning

**Input**: "Delete old user data to comply with GDPR right to erasure requests"

**Output Plan**:

```yaml
plan:
  objective: Safely delete user data per GDPR erasure request
  
  context:
    background: GDPR Article 17 requires deletion of personal data upon request
    constraints:
      - Legal requirement with strict timelines (30 days)
      - Audit trail required
      - Cannot impact other users' data
    assumptions:
      - User identity verified
      - Deletion request is valid and authorized
  
  phases:
    - name: Verification
      description: Validate request and scope data to delete
      subtasks:
        - id: gdpr-verify-scope
          description: Identify all data associated with user
          agent: researcher
          outputs: [data_inventory_report]
          success_criteria: Complete inventory of user data across all systems
          estimated_effort: medium
          risks:
            - Incomplete data identification
    
    - name: Safe Deletion
      description: Execute deletion with verification
      subtasks:
        - id: gdpr-backup
          description: Create point-in-time backup before deletion
          agent: deployer
          inputs: [data_inventory_report]
          outputs: [backup_verified]
          success_criteria: Backup created and verified restorable
          estimated_effort: small
          risks:
            - Backup failure
          
        - id: gdpr-delete
          description: Execute data deletion per inventory
          agent: deployer
          inputs: [data_inventory_report, backup_verified]
          outputs: [deletion_log]
          success_criteria: All identified data deleted, no cross-user impact
          dependencies: [gdpr-backup]
          estimated_effort: medium
          risks:
            - Accidental deletion of wrong data
            - Referential integrity violations
        
        - id: gdpr-verify
          description: Confirm deletion completion
          agent: tester
          inputs: [deletion_log, data_inventory_report]
          outputs: [verification_report]
          success_criteria: No user data remains in any system
          dependencies: [gdpr-delete]
          estimated_effort: medium
  
  risks:
    - description: Incomplete data deletion (regulatory violation)
      likelihood: medium
      impact: critical
      mitigation: Comprehensive inventory, multi-system verification
    
    - description: Wrong user data deleted
      likelihood: low
      impact: critical
      mitigation: Double-check user ID, dry-run first, backup available
    
    - description: System instability from deletions
      likelihood: medium
      impact: high
      mitigation: Test deletion in staging, monitor referential integrity
    
    - description: Backup corruption prevents recovery
      likelihood: low
      impact: high
      mitigation: Verify backup integrity before deletion
  
  timeline:
    estimated_duration: 3-5 days
    critical_path: [gdpr-verify-scope, gdpr-backup, gdpr-delete, gdpr-verify]
    milestones:
      - name: Scope Defined
        criteria: All data locations identified
      - name: Backup Complete
        criteria: Verified backup available
      - name: Deletion Executed
        criteria: All data removed
      - name: Verification Complete
        criteria: Audit report confirms compliance
  
  rollback_strategy:
    conditions:
      - Wrong data deleted
      - System instability detected
      - Regulatory compliance questioned
    steps:
      - Halt all deletion operations
      - Assess scope of incorrect deletion
      - Restore from backup if necessary
      - Document incident for legal review
    verification:
      - Data integrity verified
      - Legal compliance confirmed
      - Audit trail complete
  
  human_approval_required:
    - Final deletion execution (destructive, legal impact)
    - Backup destruction (if choosing to remove backup)
```
