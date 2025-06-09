//
//  DeleteModule_BatchTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for batch deletion functionality in the Delete module
class DeleteModule_BatchTest: XCTestCase {
    /// Database instance for testing
    var db: CuttDB!
    /// Mock service for testing
    var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "batch_test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "status TEXT",
            "created_at INTEGER"
        ]
        static let records = [
            ["id": 1, "name": "Record 1", "status": "active", "created_at": 1000],
            ["id": 2, "name": "Record 2", "status": "active", "created_at": 1500],
            ["id": 3, "name": "Record 3", "status": "inactive", "created_at": 2000],
            ["id": 4, "name": "Record 4", "status": "active", "created_at": 2500],
            ["id": 5, "name": "Record 5", "status": "inactive", "created_at": 3000]
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
        
        // Insert test data
        for record in TestData.records {
            try? db.insert(
                table: TestData.tableName,
                data: record
            )
        }
    }
    
    override func tearDown() {
        // Clean up test table
        try? db.dropTable(name: TestData.tableName)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic batch delete functionality
    func testBasicBatchDelete() {
        // Arrange
        let condition = ["status": "inactive"]
        
        // Act
        let result = try? db.deleteBatch(
            table: TestData.tableName,
            where: condition
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 2)
        
        // Verify remaining records
        let queryResult = try? db.select(table: TestData.tableName)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 3)
    }
    
    /// Test batch delete with transaction
    func testBatchDeleteWithTransaction() {
        // Arrange
        let condition = ["status": "active"]
        
        // Act
        try? db.beginTransaction()
        let result = try? db.deleteBatch(
            table: TestData.tableName,
            where: condition
        )
        try? db.commitTransaction()
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 3)
        
        // Verify remaining records
        let queryResult = try? db.select(table: TestData.tableName)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 2)
    }
    
    /// Test batch delete rollback
    func testBatchDeleteRollback() {
        // Arrange
        let condition = ["status": "active"]
        
        // Act
        try? db.beginTransaction()
        let result = try? db.deleteBatch(
            table: TestData.tableName,
            where: condition
        )
        try? db.rollbackTransaction()
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 3)
        
        // Verify no records were deleted
        let queryResult = try? db.select(table: TestData.tableName)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 5)
    }
    
    /// Test batch delete with invalid condition
    func testBatchDeleteWithInvalidCondition() {
        // Arrange
        let invalidCondition = ["invalid_column": "value"]
        
        // Act
        let result = try? db.deleteBatch(
            table: TestData.tableName,
            where: invalidCondition
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 0)
        
        // Verify no records were deleted
        let queryResult = try? db.select(table: TestData.tableName)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 5)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let condition = ["status": "active"]
        
        // Act & Assert
        measure {
            _ = try? db.deleteBatch(
                table: TestData.tableName,
                where: condition
            )
        }
    }
} 