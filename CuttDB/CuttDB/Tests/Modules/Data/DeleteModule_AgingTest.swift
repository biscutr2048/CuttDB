//
//  DeleteModule_AgingTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for aging functionality
final class DeleteModule_AgingTest: CuttDBTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    
    /// Test data structure
    private struct TestData: Codable {
        let id: String
        let name: String
        let age: Int
        let createdAt: Date
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        db = CuttDB(configuration: config)
        
        // Create test table
        try! db.createTable(name: "test_table", columns: ["id", "name", "age", "created_at"])
    }
    
    override func tearDown() {
        try! db.dropTable(name: "test_table")
        db = nil
        super.tearDown()
    }
    
    /// Test basic aging functionality
    func testBasicAging() throws {
        // Insert test data
        let now = Date()
        let oldDate = now.addingTimeInterval(-86400) // 1 day ago
        
        let data1 = TestData(id: "1", name: "Test1", age: 20, createdAt: now)
        let data2 = TestData(id: "2", name: "Test2", age: 30, createdAt: oldDate)
        
        try db.insert(table: "test_table", data: data1)
        try db.insert(table: "test_table", data: data2)
        
        // Delete old records
        try db.deleteAging(table: "test_table", column: "created_at", age: 43200) // 12 hours
        
        // Verify results
        let result = try db.queryList(from: "test_table")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0]["id"] as? String, "1")
    }
    
    /// Test aging with custom condition
    func testAgingWithCondition() throws {
        // Insert test data
        let now = Date()
        let oldDate = now.addingTimeInterval(-86400) // 1 day ago
        
        let data1 = TestData(id: "1", name: "Test1", age: 20, createdAt: now)
        let data2 = TestData(id: "2", name: "Test2", age: 30, createdAt: oldDate)
        
        try db.insert(table: "test_table", data: data1)
        try db.insert(table: "test_table", data: data2)
        
        // Delete old records with condition
        try db.deleteAging(table: "test_table", column: "created_at", age: 43200, where: "age > 25")
        
        // Verify results
        let result = try db.queryList(from: "test_table")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0]["id"] as? String, "1")
    }
    
    /// Test aging with multiple conditions
    func testAgingWithMultipleConditions() throws {
        // Insert test data
        let now = Date()
        let oldDate = now.addingTimeInterval(-86400) // 1 day ago
        
        let data1 = TestData(id: "1", name: "Test1", age: 20, createdAt: now)
        let data2 = TestData(id: "2", name: "Test2", age: 30, createdAt: oldDate)
        let data3 = TestData(id: "3", name: "Test3", age: 40, createdAt: oldDate)
        
        try db.insert(table: "test_table", data: data1)
        try db.insert(table: "test_table", data: data2)
        try db.insert(table: "test_table", data: data3)
        
        // Delete old records with multiple conditions
        try db.deleteAging(table: "test_table", column: "created_at", age: 43200, where: "age > 25 AND name LIKE 'Test%'")
        
        // Verify results
        let result = try db.queryList(from: "test_table")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0]["id"] as? String, "1")
    }
    
    /// Test aging with invalid parameters
    func testAgingWithInvalidParameters() throws {
        // Test with invalid table name
        XCTAssertThrowsError(try db.deleteAging(table: "invalid_table", column: "created_at", age: 43200))
        
        // Test with invalid column name
        XCTAssertThrowsError(try db.deleteAging(table: "test_table", column: "invalid_column", age: 43200))
        
        // Test with invalid age value
        XCTAssertThrowsError(try db.deleteAging(table: "test_table", column: "created_at", age: -1))
    }
    
    /// Test aging with empty table
    func testAgingWithEmptyTable() throws {
        // Delete from empty table
        try db.deleteAging(table: "test_table", column: "created_at", age: 43200)
        
        // Verify table is still empty
        let result = try db.queryList(from: "test_table")
        XCTAssertTrue(result.isEmpty)
    }
} 
