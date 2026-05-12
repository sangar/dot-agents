---
description: Testing standards and best practices for all projects
alwaysApply: true
---

# Testing Guidelines

## Always Run Tests After Code Changes

After making changes to code, **ALWAYS** run the relevant tests to ensure nothing is broken.

## Test-Driven Development (TDD)

- Write tests before or alongside code changes
- Follow the red-green-refactor cycle when appropriate
- Tests serve as executable documentation

## Testing Practices

### General

- Keep tests fast and deterministic
- One logical assertion per test when possible
- Use descriptive test names that explain the expected behavior
- Group related tests with describe/context blocks
- Test outputs/behavior, not implementation
- Use test doubles sparingly — only mock external dependencies (APIs, Stripe), not internal code
- Tests should not break on refactoring
- Don't test individual parameters separately when they use the same code path

### Test Coverage

- Aim for meaningful coverage, not just high percentages
- Cover edge cases and error paths
- Test public APIs, not implementation details

### Assertions

- Make assertions specific and meaningful
- Avoid testing multiple unrelated things in one test
- Check both positive and negative cases

## Debugging Failures

- Read error messages carefully
- Isolate failing tests
- Add console logs or debuggers temporarily if needed
- Fix the root cause, not just the symptom

## Language-Specific Guidelines

### JavaScript/TypeScript

- Use Jest, Vitest, or the project's preferred framework
- Mock external dependencies appropriately
- Clean up mocks between tests

### Python

- Use pytest for most projects
- Use fixtures for shared setup
- Prefer parametrized tests for multiple similar cases

## CI/CD

- All tests must pass before merging
- Don't skip failing tests; fix them
