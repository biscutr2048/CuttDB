//
//  CreateModule_AutoCreateTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for auto-create functionality
class CreateModule_AutoCreateTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "test_table"
        static let simpleRecord: [String: Any] = [
            "id": 1,
            "name": "Test",
            "age": 25,
            "email": "test@example.com",
            "created_at": Date().timeIntervalSince1970
        ]
        
        static let complexRecord: [String: Any] = [
            "id": 2,
            "name": "Complex",
            "profile": [
                "age": 30,
                "city": "Beijing",
                "contact": [
                    "email": "complex@example.com",
                    "phone": "123456"
                ]
            ],
            "tags": ["swift", "macos"],
            "meta": NSNull(),
            "history": [
                [
                    "date": "2024-06-01",
                    "action": "login"
                ],
                [
                    "date": "2024-06-02",
                    "action": "logout"
                ]
            ]
        ]
        
        static let recordWithSpecialTypes: [String: Any] = [
            "id": 3,
            "name": "Special",
            "is_active": true,
            "score": 95.5,
            "created_at": "2024-06-09T10:00:00Z",
            "metadata": [
                "version": 1.0,
                "flags": [1, 2, 3]
            ]
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
    
    /// Test auto-create with simple record
    func testAutoCreateWithSimpleRecord() {
        // Arrange
        let tableName = TestData.tableName
        let record = TestData.simpleRecord
        
        // Act
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: record,
            autoCreate: true
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let tableExists = try? db.tableExists(name: tableName)
        XCTAssertTrue(tableExists ?? false)
        
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "id" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "name" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "age" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "email" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "created_at" } ?? false)
    }
    
    /// Test auto-create with complex record
    func testAutoCreateWithComplexRecord() {
        // Arrange
        let tableName = TestData.tableName
        let record = TestData.complexRecord
        
        // Act
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: record,
            autoCreate: true
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let tableExists = try? db.tableExists(name: tableName)
        XCTAssertTrue(tableExists ?? false)
        
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "id" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "name" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "profile" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "tags" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "meta" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "history" } ?? false)
    }
    
    /// Test auto-create with special types
    func testAutoCreateWithSpecialTypes() {
        // Arrange
        let tableName = TestData.tableName
        let record = TestData.recordWithSpecialTypes
        
        // Act
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: record,
            autoCreate: true
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let tableExists = try? db.tableExists(name: tableName)
        XCTAssertTrue(tableExists ?? false)
        
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "id" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "name" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "is_active" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "score" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "created_at" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "metadata" } ?? false)
    }
    
    /// Test auto-create with invalid record
    func testAutoCreateWithInvalidRecord() {
        // Arrange
        let tableName = TestData.tableName
        let invalidRecord: [String: Any] = [
            "id": "invalid_id",  // Invalid type for id
            "name": 123,         // Invalid type for name
            "age": "invalid_age" // Invalid type for age
        ]
        
        // Act & Assert
        XCTAssertThrowsError(try db.insertOrUpdate(
            table: tableName,
            record: invalidRecord,
            autoCreate: true
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test auto-create with existing table
    func testAutoCreateWithExistingTable() {
        // Arrange
        let tableName = TestData.tableName
        let record = TestData.simpleRecord
        
        // Create table first
        _ = try? db.createTable(
            name: tableName,
            columns: [
                "id INTEGER PRIMARY KEY",
                "name TEXT",
                "age INTEGER",
                "email TEXT",
                "created_at INTEGER"
            ]
        )
        
        // Act
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: record,
            autoCreate: true
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let tableName = TestData.tableName
        let record = TestData.simpleRecord
        
        // Act & Assert
        measure {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record,
                autoCreate: true
            )
        }
    }
} 