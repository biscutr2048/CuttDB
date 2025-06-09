//
//  DeleteModule_AgingTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for aging functionality in the Delete module
class DeleteModule_AgingTest: XCTestCase {
    /// Database instance for testing
    var db: CuttDB!
    /// Mock service for testing
    var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "aging_test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "created_at INTEGER",
            "expires_at INTEGER"
        ]
        static let records = [
            ["id": 1, "name": "Record 1", "created_at": 1000, "expires_at": 2000],
            ["id": 2, "name": "Record 2", "created_at": 1500, "expires_at": 2500],
            ["id": 3, "name": "Record 3", "created_at": 2000, "expires_at": 3000]
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
    
    /// Test single record aging
    func testSingleRecordAging() {
        // Arrange
        let recordId = 1
        let currentTime = 2500 // After expiration
        
        // Act
        let result = try? db.deleteAgedRecords(
            table: TestData.tableName,
            currentTime: currentTime
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 1)
        
        // Verify record is deleted
        let queryResult = try? db.select(
            table: TestData.tableName,
            where: ["id": recordId]
        )
        XCTAssertNil(queryResult)
    }
    
    /// Test batch record aging
    func testBatchRecordAging() {
        // Arrange
        let currentTime = 3000 // After all records expiration
        
        // Act
        let result = try? db.deleteAgedRecords(
            table: TestData.tableName,
            currentTime: currentTime
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 3)
        
        // Verify all records are deleted
        let queryResult = try? db.select(table: TestData.tableName)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 0)
    }
    
    /// Test time-based aging
    func testTimeBasedAging() {
        // Arrange
        let currentTime = 2200 // Between record 1 and 2 expiration
        
        // Act
        let result = try? db.deleteAgedRecords(
            table: TestData.tableName,
            currentTime: currentTime
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 1)
        
        // Verify only expired record is deleted
        let queryResult = try? db.select(table: TestData.tableName)
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 2)
    }
    
    /// Test handling invalid data
    func testInvalidData() {
        // Arrange
        let invalidRecord = ["id": 4, "name": "Invalid", "created_at": "invalid", "expires_at": 3000]
        try? db.insert(table: TestData.tableName, data: invalidRecord)
        
        // Act
        let result = try? db.deleteAgedRecords(
            table: TestData.tableName,
            currentTime: 3000
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.deletedCount, 3) // Only valid records should be deleted
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let currentTime = 3000
        
        // Act & Assert
        measure {
            _ = try? db.deleteAgedRecords(
                table: TestData.tableName,
                currentTime: currentTime
            )
        }
    }
} 