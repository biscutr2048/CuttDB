//
//  InsertUpdateModule_SQLTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for SQL operations
final class InsertUpdateModule_SQLTest: CuttDBTestCase {
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
        static let invalidRecord = [
            "id": "2",
            "name": nil,
            "age": "invalid"
        ] as [String: Any]
        static let updateRecord = [
            "name": "Updated User",
            "age": 30
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
    
    /// Test SQL operations
    func testSQLOperations() {
        // Test valid insert
        let insertResult = try? db.insert(
            table: TestData.table,
            data: TestData.validRecord
        )
        XCTAssertNotNil(insertResult)
        XCTAssertTrue(insertResult ?? false)
        
        // Test invalid insert
        XCTAssertThrowsError(try db.insert(
            table: TestData.table,
            data: TestData.invalidRecord
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
        
        // Test update
        let updateSQL = "UPDATE \(TestData.table) SET name = '\(TestData.updateRecord["name"] as! String)', age = \(TestData.updateRecord["age"] as! Int) WHERE id = '1'"
        let updateResult = try? db.queryList(from: TestData.table, where: updateSQL)
        XCTAssertNotNil(updateResult)
        
        // Verify update
        let queryResult = try? db.queryList(from: TestData.table)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        
        if let record = queryResult?.first {
            XCTAssertEqual(record["name"] as? String, "Updated User")
            XCTAssertEqual(record["age"] as? Int, 30)
        }
    }
} 
