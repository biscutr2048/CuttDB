//
//  InsertUpdateModule_SQLTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for SQL operations in the InsertUpdate module
class InsertUpdateModule_SQLTest: XCTestCase {
    /// Database instance for testing
    var db: CuttDB!
    /// Mock service for testing
    var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "sql_test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "email TEXT"
        ]
        static let records = [
            ["id": 1, "name": "John Doe", "age": 30, "email": "john@example.com"],
            ["id": 2, "name": "Jane Smith", "age": 25, "email": "jane@example.com"],
            ["id": 3, "name": "Bob Johnson", "age": 35, "email": "bob@example.com"]
        ]
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
        
        // Create test table
        try? db.createTable(
            name: TestData.tableName,
            columns: TestData.columns
        )
    }
    
    override func tearDown() {
        // Clean up test table
        try? db.dropTable(name: TestData.tableName)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic insert operation
    func testBasicInsert() {
        // Arrange
        let record = TestData.records[0]
        
        // Act
        let result = try? db.insert(
            table: TestData.tableName,
            data: record
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let queryResult = try? db.select(
            table: TestData.tableName,
            where: ["id": record["id"] as! Int]
        )
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        XCTAssertEqual(queryResult?.first?["name"] as? String, record["name"] as? String)
    }
    
    /// Test insert with invalid data
    func testInsertWithInvalidData() {
        // Arrange
        let invalidRecord = ["id": "invalid", "name": "Invalid", "age": "not_a_number"]
        
        // Act & Assert
        XCTAssertThrowsError(try db.insert(
            table: TestData.tableName,
            data: invalidRecord
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test update operation
    func testUpdate() {
        // Arrange
        let record = TestData.records[0]
        try? db.insert(table: TestData.tableName, data: record)
        let updatedData = ["name": "Updated Name", "age": 31]
        
        // Act
        let result = try? db.update(
            table: TestData.tableName,
            data: updatedData,
            where: ["id": record["id"] as! Int]
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let queryResult = try? db.select(
            table: TestData.tableName,
            where: ["id": record["id"] as! Int]
        )
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        XCTAssertEqual(queryResult?.first?["name"] as? String, "Updated Name")
        XCTAssertEqual(queryResult?.first?["age"] as? Int, 31)
    }
    
    /// Test update with invalid condition
    func testUpdateWithInvalidCondition() {
        // Arrange
        let record = TestData.records[0]
        try? db.insert(table: TestData.tableName, data: record)
        let updatedData = ["name": "Updated Name"]
        
        // Act & Assert
        XCTAssertThrowsError(try db.update(
            table: TestData.tableName,
            data: updatedData,
            where: ["invalid_column": "value"]
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test upsert operation
    func testUpsert() {
        // Arrange
        let record = TestData.records[0]
        let updatedData = ["name": "Upserted Name", "age": 32]
        
        // Act
        let result = try? db.upsert(
            table: TestData.tableName,
            data: updatedData,
            where: ["id": record["id"] as! Int]
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let queryResult = try? db.select(
            table: TestData.tableName,
            where: ["id": record["id"] as! Int]
        )
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        XCTAssertEqual(queryResult?.first?["name"] as? String, "Upserted Name")
        XCTAssertEqual(queryResult?.first?["age"] as? Int, 32)
    }
    
    /// Test batch insert operation
    func testBatchInsert() {
        // Act
        let result = try? db.insertBatch(
            table: TestData.tableName,
            data: TestData.records
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let queryResult = try? db.select(table: TestData.tableName)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, TestData.records.count)
    }
    
    /// Test batch insert with invalid data
    func testBatchInsertWithInvalidData() {
        // Arrange
        let invalidRecords = [
            ["id": "invalid", "name": "Invalid"],
            ["id": 2, "name": "Valid"]
        ]
        
        // Act & Assert
        XCTAssertThrowsError(try db.insertBatch(
            table: TestData.tableName,
            data: invalidRecords
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        var largeDataset: [[String: Any]] = []
        for i in 1...1000 {
            largeDataset.append([
                "id": i,
                "name": "Record \(i)",
                "age": i % 100,
                "email": "record\(i)@example.com"
            ])
        }
        
        // Act & Assert
        measure {
            _ = try? db.insertBatch(
                table: TestData.tableName,
                data: largeDataset
            )
        }
    }
} 