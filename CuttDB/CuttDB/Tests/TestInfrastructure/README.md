# CuttDB Test Infrastructure

## Overview
This directory contains the core testing infrastructure for CuttDB, providing base classes, utilities, and mock objects for testing.

## Directory Structure
```
Tests/
├── TestInfrastructure/     # Core testing infrastructure
│   ├── CuttDBTest.swift    # Base test class with common utilities
│   ├── MockCuttDBService.swift  # Mock service for testing
│   └── README.md           # This documentation
├── Core/                   # Core functionality tests
├── Modules/               # Module-specific tests
│   ├── Align/            # Alignment module tests
│   ├── Create/           # Creation module tests
│   ├── Data/             # Data operation tests
│   ├── Mechanism/        # Mechanism tests
│   └── Select/           # Selection module tests
└── Utils/                # Utility function tests
```

## Test Organization

### TestInfrastructure
- `CuttDBTest.swift`: Base test class that provides:
  - Common setup and teardown methods
  - Database initialization utilities
  - Test data generation helpers
  - Assertion utilities

- `MockCuttDBService.swift`: Mock service implementation that:
  - Simulates database operations
  - Provides controlled test environments
  - Enables isolated testing of components

### Core Tests
Tests for core functionality including:
- Database initialization
- Configuration management
- Core data structures
- Basic operations

### Module Tests
Each module has its own test directory with:
- Functional tests
- Integration tests
- Performance tests
- Edge case tests

### Utility Tests
Tests for utility functions and helpers:
- Data conversion
- Formatting
- Validation
- Helper methods

## Best Practices

1. **Test Organization**
   - Group related tests in appropriate directories
   - Use clear, descriptive test names
   - Follow the pattern: `[Module]_[Functionality]_[TestType]`

2. **Test Structure**
   - Use `CuttDBTest` as the base class
   - Follow the Arrange-Act-Assert pattern
   - Include setup and teardown where needed

3. **Mocking**
   - Use `MockCuttDBService` for isolated testing
   - Create specific mocks for complex scenarios
   - Document mock behavior

4. **Assertions**
   - Use appropriate assertion methods
   - Include clear failure messages
   - Test both success and failure cases

5. **Performance**
   - Use `measure` blocks for performance tests
   - Include baseline measurements
   - Document performance requirements

## Running Tests

1. **Individual Tests**
   ```swift
   // Run a single test
   func testSpecificFunctionality() {
       // Test implementation
   }
   ```

2. **Test Groups**
   ```swift
   // Group related tests
   class ModuleTests: CuttDBTest {
       // Test implementations
   }
   ```

3. **Performance Tests**
   ```swift
   func testPerformance() {
       measure {
           // Performance test implementation
       }
   }
   ```

## Adding New Tests

1. **Choose Location**
   - Place tests in appropriate directory
   - Follow existing naming conventions
   - Maintain directory structure

2. **Test Implementation**
   - Inherit from `CuttDBTest`
   - Use provided utilities
   - Follow best practices

3. **Documentation**
   - Add comments for complex tests
   - Document test requirements
   - Update this README if needed

## Maintenance

1. **Regular Updates**
   - Keep tests up to date with code changes
   - Remove obsolete tests
   - Update documentation

2. **Code Coverage**
   - Maintain high test coverage
   - Focus on critical paths
   - Test edge cases

3. **Performance**
   - Monitor test execution time
   - Optimize slow tests
   - Update baselines as needed 