//
//  MechanismModule_ResponseTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for response mechanism functionality
class MechanismModule_ResponseTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "value INTEGER",
            "created_at INTEGER"
        ]
        
        static let successRecord: [String: Any] = [
            "id": 1,
            "name": "Test",
            "value": 100,
            "created_at": Date().timeIntervalSince1970
        ]
        
        static let errorRecord: [String: Any] = [
            "id": "invalid_id",  // Invalid type
            "name": 123,         // Invalid type
            "value": "invalid",  // Invalid type
            "created_at": Date().timeIntervalSince1970
        ]
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.tableName)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test successful response
    func testSuccessfulResponse() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.successRecord
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Act
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: record
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.affectedRows, 1)
    }
    
    /// Test error response
    func testErrorResponse() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.errorRecord
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Act & Assert
        XCTAssertThrowsError(try db.insertOrUpdate(
            table: tableName,
            record: record
        )) { error in
            XCTAssertTrue(error is CuttDBError)
            if let dbError = error as? CuttDBError {
                XCTAssertNotNil(dbError.message)
                XCTAssertNotNil(dbError.code)
            }
        }
    }
    
    /// Test response with custom error
    func testResponseWithCustomError() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.successRecord
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Mock custom error
        mockService.shouldThrowError = true
        mockService.customError = CuttDBError(
            code: "CUSTOM_ERROR",
            message: "Custom error message"
        )
        
        // Act & Assert
        XCTAssertThrowsError(try db.insertOrUpdate(
            table: tableName,
            record: record
        )) { error in
            XCTAssertTrue(error is CuttDBError)
            if let dbError = error as? CuttDBError {
                XCTAssertEqual(dbError.code, "CUSTOM_ERROR")
                XCTAssertEqual(dbError.message, "Custom error message")
            }
        }
    }
    
    /// Test response with validation
    func testResponseWithValidation() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.successRecord
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Act
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: record,
            validate: true
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.affectedRows, 1)
        
        // Verify validation
        let queryResult = try? db.select(
            table: tableName,
            where: "id = ?",
            params: [1]
        )
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
    }
    
    /// Test response with transaction
    func testResponseWithTransaction() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.successRecord
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Act
        let result = try? db.transaction { transaction in
            try transaction.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        XCTAssertNil(result?.error)
        XCTAssertEqual(result?.affectedRows, 1)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.successRecord
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Act & Assert
        measure {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
    }
} 