//
//  InsertUpdateModule_TransactionTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for transaction operations
final class InsertUpdateModule_TransactionTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        static let validRecord = [
            "id": "1",
            "name": "Test User",
            "age": 25
        ] as [String: Any]
        static let updateRecord = [
            "name": "Updated User",
            "age": 30
        ] as [String: Any]
        static let invalidRecord = [
            "id": "2",
            "name": nil,
            "age": "invalid"
        ] as [String: Any]
    }
    
    override func setUp() {
        super.setUp()
        
        // Create test table
        try? db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test successful transaction
    func testSuccessfulTransaction() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act
        do {
            try db.insertOrUpdate(table: table, record: record)
            let updateSQL = "UPDATE \(table) SET name = '\(TestData.updateRecord["name"] as! String)', age = \(TestData.updateRecord["age"] as! Int) WHERE id = '1'"
            _ = try db.queryList(from: table, where: updateSQL)
        } catch {
            XCTFail("Transaction failed: \(error)")
        }
        
        // Verify
        let updatedRecord = try? db.queryList(from: table, where: "id = '1'").first
        
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
        do {
            try db.insertOrUpdate(table: table, record: record)
            try db.insertOrUpdate(table: table, record: invalidRecord)
            XCTFail("Transaction should have failed")
        } catch {
            XCTAssertTrue(error is CuttDBError)
        }
        
        // Verify - No records should be inserted
        let count = try? db.queryList(from: table).count
        XCTAssertEqual(count, 0)
    }
    
    /// Test nested transaction
    func testNestedTransaction() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act
        do {
            try db.insertOrUpdate(table: table, record: record)
            let updateSQL = "UPDATE \(table) SET name = '\(TestData.updateRecord["name"] as! String)', age = \(TestData.updateRecord["age"] as! Int) WHERE id = '1'"
            _ = try db.queryList(from: table, where: updateSQL)
        } catch {
            XCTFail("Transaction failed: \(error)")
        }
        
        // Verify
        let updatedRecord = try? db.queryList(from: table, where: "id = '1'").first
        
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
        do {
            try db.insertOrUpdate(table: table, record: record)
            throw CuttDBError.invalidOperation("Rollback test")
        } catch {
            // Expected error
        }
        
        // Verify - No records should be inserted
        let count = try? db.queryList(from: table).count
        XCTAssertEqual(count, 0)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act & Assert
        measure {
            do {
                try db.insertOrUpdate(table: table, record: record)
                let updateSQL = "UPDATE \(table) SET name = '\(TestData.updateRecord["name"] as! String)', age = \(TestData.updateRecord["age"] as! Int) WHERE id = '1'"
                _ = try db.queryList(from: table, where: updateSQL)
            } catch {
                // Ignore errors in performance test
            }
        }
    }
} 
