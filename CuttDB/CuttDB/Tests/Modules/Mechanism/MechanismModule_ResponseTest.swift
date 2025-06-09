//
//  MechanismModule_ResponseTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for response handling
final class MechanismModule_ResponseTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = ["id", "name", "age"]
        
        static let validData: [String: Any] = [
            "id": "1",
            "name": "Test User",
            "age": 25
        ]
        
        static let invalidData: [String: Any] = [
            "id": "invalid",
            "name": 123,
            "age": "not a number"
        ]
    }
    
    override func setUp() {
        super.setUp()
        
        // Create test table
        try? db.createTable(
            name: TestData.table,
            columns: TestData.columns
        )
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test successful response
    func testSuccessfulResponse() throws {
        // Insert data
        let result = try db.insert(table: TestData.table, data: TestData.validData)
        XCTAssertTrue(result)
        
        // Query data
        let queryResult = try db.queryList(from: TestData.table)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult.count, 1)
        
        if let record = queryResult.first {
            XCTAssertEqual(record["id"] as? String, "1")
            XCTAssertEqual(record["name"] as? String, "Test User")
            XCTAssertEqual(record["age"] as? Int, 25)
        }
    }
    
    /// Test error response
    func testErrorResponse() throws {
        // Test invalid data
        XCTAssertThrowsError(try db.insert(table: TestData.table, data: TestData.invalidData)) { error in
            XCTAssertTrue(error is CuttDBError)
        }
        
        // Test invalid table
        XCTAssertThrowsError(try db.queryList(from: "non_existent_table")) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test empty response
    func testEmptyResponse() throws {
        // Query empty table
        let result = try db.queryList(from: TestData.table)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 0)
    }
    
    /// Test null response
    func testNullResponse() throws {
        // Insert null values
        let nullData: [String: Any] = [
            "id": "1",
            "name": NSNull(),
            "age": NSNull()
        ]
        
        try db.insert(table: TestData.table, data: nullData)
        
        // Query data
        let result = try db.queryList(from: TestData.table)
        XCTAssertNotNil(result)
        XCTAssertEqual(result.count, 1)
        
        if let record = result.first {
            XCTAssertEqual(record["id"] as? String, "1")
            XCTAssertNil(record["name"])
            XCTAssertNil(record["age"])
        }
    }
} 