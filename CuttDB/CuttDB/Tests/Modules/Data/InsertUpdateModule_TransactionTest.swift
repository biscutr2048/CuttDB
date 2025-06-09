//
//  InsertUpdateModule_TransactionTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for transaction-based insert and update operations
final class InsertUpdateModule_TransactionTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "created_at INTEGER"
        ]
        
        static let validRecord: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "age": 25,
            "created_at": Date().timeIntervalSince1970
        ]
        
        static let invalidRecord: [String: Any] = [
            "id": "invalid",
            "name": 123,
            "age": "not a number",
            "created_at": "invalid date"
        ]
        
        static let updateRecord: [String: Any] = [
            "name": "Updated User",
            "age": 30
        ]
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
        
        // Create test table
        _ = try? db.createTable(
            name: TestData.table,
            columns: TestData.columns
        )
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test successful transaction
    func testSuccessfulTransaction() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act
        let result = try? db.transaction { db in
            try db.insertOrUpdate(
                table: table,
                record: record
            )
            try db.update(
                table: table,
                record: TestData.updateRecord,
                where: "id = ?",
                params: [1]
            )
        }
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let updatedRecord = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        ).first
        
        XCTAssertNotNil(updatedRecord)
        XCTAssertEqual(updatedRecord?["name"] as? String, "Updated User")
        XCTAssertEqual(updatedRecord?["age"] as? Int, 30)
    }
    
    /// Test failed transaction
    func testFailedTransaction() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        let invalidRecord = TestData.invalidRecord
        
        // Act & Assert
        XCTAssertThrowsError(try db.transaction { db in
            try db.insertOrUpdate(
                table: table,
                record: record
            )
            try db.insertOrUpdate(
                table: table,
                record: invalidRecord
            )
        }) { error in
            XCTAssertTrue(error is CuttDBError)
        }
        
        // Verify - No records should be inserted
        let count = try? db.count(table: table)
        XCTAssertEqual(count, 0)
    }
    
    /// Test nested transaction
    func testNestedTransaction() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act
        let result = try? db.transaction { db in
            try db.insertOrUpdate(
                table: table,
                record: record
            )
            
            try db.transaction { db in
                try db.update(
                    table: table,
                    record: TestData.updateRecord,
                    where: "id = ?",
                    params: [1]
                )
            }
        }
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let updatedRecord = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        ).first
        
        XCTAssertNotNil(updatedRecord)
        XCTAssertEqual(updatedRecord?["name"] as? String, "Updated User")
        XCTAssertEqual(updatedRecord?["age"] as? Int, 30)
    }
    
    /// Test transaction rollback
    func testTransactionRollback() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act
        let result = try? db.transaction { db in
            try db.insertOrUpdate(
                table: table,
                record: record
            )
            throw CuttDBError.invalidOperation("Rollback test")
        }
        
        // Assert
        XCTAssertNil(result)
        
        // Verify - No records should be inserted
        let count = try? db.count(table: table)
        XCTAssertEqual(count, 0)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act & Assert
        measure {
            _ = try? db.transaction { db in
                try db.insertOrUpdate(
                    table: table,
                    record: record
                )
                try db.update(
                    table: table,
                    record: TestData.updateRecord,
                    where: "id = ?",
                    params: [1]
                )
            }
        }
    }
} 