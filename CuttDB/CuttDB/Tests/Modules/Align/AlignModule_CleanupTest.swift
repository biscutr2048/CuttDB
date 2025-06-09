//
//  AlignModule_CleanupTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for cleanup operations
final class AlignModule_CleanupTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "created_at INTEGER"
        ]
        
        static let record: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "age": 25,
            "created_at": Date().timeIntervalSince1970
        ]
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic cleanup operation
    func testBasicCleanup() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let record = TestData.record
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Insert test data
        _ = try? db.insert(
            table: table,
            data: record
        )
        
        // Act
        let result = try? db.cleanup(
            service: mockService
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let records = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        )
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records?.count, 1)
    }
    
    /// Test cleanup with multiple tables
    func testCleanupWithMultipleTables() {
        // Arrange
        let table1 = "table1"
        let table2 = "table2"
        let columns = TestData.columns
        let record = TestData.record
        
        // Create test tables
        _ = try? db.createTable(
            name: table1,
            columns: columns
        )
        
        _ = try? db.createTable(
            name: table2,
            columns: columns
        )
        
        // Insert test data
        _ = try? db.insert(
            table: table1,
            data: record
        )
        
        _ = try? db.insert(
            table: table2,
            data: record
        )
        
        // Act
        let result = try? db.cleanup(
            service: mockService
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let records1 = try? db.select(
            table: table1,
            where: "id = ?",
            params: [1]
        )
        
        XCTAssertNotNil(records1)
        XCTAssertEqual(records1?.count, 1)
        
        let records2 = try? db.select(
            table: table2,
            where: "id = ?",
            params: [1]
        )
        
        XCTAssertNotNil(records2)
        XCTAssertEqual(records2?.count, 1)
    }
    
    /// Test cleanup with empty table
    func testCleanupWithEmptyTable() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Act
        let result = try? db.cleanup(
            service: mockService
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let records = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        )
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records?.count, 0)
    }
    
    /// Test cleanup with non-existent table
    func testCleanupWithNonExistentTable() {
        // Act
        let result = try? db.cleanup(
            service: mockService
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.success ?? true)
    }
    
    /// Test cleanup with invalid data
    func testCleanupWithInvalidData() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let invalidRecord: [String: Any] = [
            "id": "invalid",
            "name": 123,
            "age": "not a number",
            "created_at": "invalid date"
        ]
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Insert invalid data
        _ = try? db.insert(
            table: table,
            data: invalidRecord
        )
        
        // Act
        let result = try? db.cleanup(
            service: mockService
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.success ?? true)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let record = TestData.record
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Insert test data
        _ = try? db.insert(
            table: table,
            data: record
        )
        
        // Act & Assert
        measure {
            _ = try? db.cleanup(
                service: mockService
            )
        }
    }
} 