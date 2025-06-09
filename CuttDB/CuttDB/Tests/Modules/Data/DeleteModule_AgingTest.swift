//
//  DeleteModule_AgingTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for aging operations
final class DeleteModule_AgingTest: CuttDBTestCase {
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
    
    /// Test basic aging operation
    func testBasicAging() {
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
        let result = try? db.deleteAgedRecords(
            table: table,
            ageColumn: "created_at",
            maxAge: 3600
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 0)
        
        // Verify
        let records = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        )
        
        XCTAssertNil(records)
    }
    
    /// Test aging with old records
    func testAgingWithOldRecords() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let oldRecord: [String: Any] = [
            "id": 1,
            "name": "Old User",
            "age": 25,
            "created_at": Date().timeIntervalSince1970 - 7200
        ]
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Insert test data
        _ = try? db.insert(
            table: table,
            data: oldRecord
        )
        
        // Act
        let result = try? db.deleteAgedRecords(
            table: table,
            ageColumn: "created_at",
            maxAge: 3600
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 1)
        
        // Verify
        let records = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        )
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records?.count, 0)
    }
    
    /// Test aging with mixed records
    func testAgingWithMixedRecords() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let oldRecord: [String: Any] = [
            "id": 1,
            "name": "Old User",
            "age": 25,
            "created_at": Date().timeIntervalSince1970 - 7200
        ]
        let newRecord: [String: Any] = [
            "id": 2,
            "name": "New User",
            "age": 30,
            "created_at": Date().timeIntervalSince1970
        ]
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Insert test data
        _ = try? db.insert(
            table: table,
            data: oldRecord
        )
        
        _ = try? db.insert(
            table: table,
            data: newRecord
        )
        
        // Act
        let result = try? db.deleteAgedRecords(
            table: table,
            ageColumn: "created_at",
            maxAge: 3600
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 1)
        
        // Verify
        let records = try? db.select(
            table: table,
            where: "id = ?",
            params: [2]
        )
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records?.count, 1)
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
            _ = try? db.deleteAgedRecords(
                table: table,
                ageColumn: "created_at",
                maxAge: 3600
            )
        }
    }
} 