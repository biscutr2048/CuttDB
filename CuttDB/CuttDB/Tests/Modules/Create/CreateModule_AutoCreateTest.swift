//
//  CreateModule_AutoCreateTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for auto-create functionality
final class CreateModule_AutoCreateTest: CuttDBTestCase {
    // MARK: - Properties
    
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER"
        ]
    }
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        db = CuttDB(configuration: config)
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        db = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test auto-create table
    func testAutoCreateTable() {
        // Insert data with auto-create
        let record: [String: Any] = [
            "id": "1",
            "name": "Test",
            "age": 25
        ]
        
        let result = try? db.insertOrUpdate(table: TestData.table, record: record, autoCreate: true)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify table exists
        XCTAssertTrue(try db.tableExists(name: TestData.table))
    }
    
    /// Test auto-create with invalid data
    func testAutoCreateWithInvalidData() {
        // Try to insert invalid data
        let record: [String: Any] = [:]
        
        let result = try? db.insertOrUpdate(table: TestData.table, record: record, autoCreate: true)
        XCTAssertNotNil(result)
        XCTAssertFalse(result?.success ?? true)
    }
} 