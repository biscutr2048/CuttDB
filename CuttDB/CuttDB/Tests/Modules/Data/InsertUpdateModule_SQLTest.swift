//
//  InsertUpdateModule_SQLTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for SQL-based insert and update operations
final class InsertUpdateModule_SQLTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "created_at INTEGER"
        ]
        
        static let validRecord: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "age": 25,
            "created_at": Date().timeIntervalSince1970
        ]
        
        static let invalidRecord: [String: Any] = [
            "id": "invalid",
            "name": 123,
            "age": "not a number",
            "created_at": "invalid date"
        ]
        
        static let updateRecord: [String: Any] = [
            "name": "Updated User",
            "age": 30
        ]
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
        
        // Create test table
        _ = try? db.createTable(
            name: TestData.table,
            columns: TestData.columns
        )
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic insert operation
    func testBasicInsert() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act
        let result = try? db.insertOrUpdate(
            table: table,
            record: record
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let count = try? db.count(table: table)
        XCTAssertEqual(count, 1)
    }
    
    /// Test insert with invalid data
    func testInsertWithInvalidData() {
        // Arrange
        let table = TestData.table
        let record = TestData.invalidRecord
        
        // Act & Assert
        XCTAssertThrowsError(try db.insertOrUpdate(
            table: table,
            record: record
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test update operation
    func testUpdate() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        let updateRecord = TestData.updateRecord
        
        // Insert initial record
        _ = try? db.insertOrUpdate(
            table: table,
            record: record
        )
        
        // Act
        let result = try? db.update(
            table: table,
            record: updateRecord,
            where: "id = ?",
            params: [1]
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let updatedRecord = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        ).first
        
        XCTAssertNotNil(updatedRecord)
        XCTAssertEqual(updatedRecord?["name"] as? String, "Updated User")
        XCTAssertEqual(updatedRecord?["age"] as? Int, 30)
    }
    
    /// Test update with invalid data
    func testUpdateWithInvalidData() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        let invalidUpdate = TestData.invalidRecord
        
        // Insert initial record
        _ = try? db.insertOrUpdate(
            table: table,
            record: record
        )
        
        // Act & Assert
        XCTAssertThrowsError(try db.update(
            table: table,
            record: invalidUpdate,
            where: "id = ?",
            params: [1]
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test insert or update operation
    func testInsertOrUpdate() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act - First insert
        let insertResult = try? db.insertOrUpdate(
            table: table,
            record: record
        )
        
        // Assert
        XCTAssertNotNil(insertResult)
        XCTAssertTrue(insertResult?.success ?? false)
        
        // Act - Then update
        let updateResult = try? db.insertOrUpdate(
            table: table,
            record: record
        )
        
        // Assert
        XCTAssertNotNil(updateResult)
        XCTAssertTrue(updateResult?.success ?? false)
        
        // Verify
        let count = try? db.count(table: table)
        XCTAssertEqual(count, 1)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let table = TestData.table
        let record = TestData.validRecord
        
        // Act & Assert
        measure {
            _ = try? db.insertOrUpdate(
                table: table,
                record: record
            )
        }
    }
} 