//
//  AlignModule_UpgradeTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for database upgrade functionality
class AlignModule_UpgradeTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "test_table"
        static let oldColumns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "email TEXT"
        ]
        
        static let newColumns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "email TEXT",
            "phone TEXT",
            "address TEXT",
            "created_at INTEGER"
        ]
        
        static let oldRecord: [String: Any] = [
            "id": 1,
            "name": "Test",
            "age": 25,
            "email": "test@example.com"
        ]
        
        static let newRecord: [String: Any] = [
            "id": 1,
            "name": "Test",
            "age": 25,
            "email": "test@example.com",
            "phone": "123456",
            "address": "Test Address",
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
    
    /// Test basic table upgrade
    func testBasicTableUpgrade() {
        // Arrange
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let newColumns = TestData.newColumns
        
        // Create table with old schema
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // Insert old record
        _ = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.oldRecord
        )
        
        // Act
        let result = try? db.upgradeTable(
            name: tableName,
            columns: newColumns
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "phone" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "address" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "created_at" } ?? false)
    }
    
    /// Test data preservation during upgrade
    func testDataPreservation() {
        // Arrange
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let newColumns = TestData.newColumns
        
        // Create table with old schema
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // Insert old record
        _ = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.oldRecord
        )
        
        // Act
        _ = try? db.upgradeTable(
            name: tableName,
            columns: newColumns
        )
        
        // Verify
        let queryResult = try? db.select(
            table: tableName,
            where: "id = ?",
            params: [1]
        )
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        
        if let firstRecord = queryResult?.first {
            XCTAssertEqual(firstRecord["id"] as? Int, 1)
            XCTAssertEqual(firstRecord["name"] as? String, "Test")
            XCTAssertEqual(firstRecord["age"] as? Int, 25)
            XCTAssertEqual(firstRecord["email"] as? String, "test@example.com")
        }
    }
    
    /// Test upgrade with new data
    func testUpgradeWithNewData() {
        // Arrange
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let newColumns = TestData.newColumns
        
        // Create table with old schema
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // Insert old record
        _ = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.oldRecord
        )
        
        // Upgrade table
        _ = try? db.upgradeTable(
            name: tableName,
            columns: newColumns
        )
        
        // Act
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.newRecord
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let queryResult = try? db.select(
            table: tableName,
            where: "id = ?",
            params: [1]
        )
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        
        if let firstRecord = queryResult?.first {
            XCTAssertEqual(firstRecord["phone"] as? String, "123456")
            XCTAssertEqual(firstRecord["address"] as? String, "Test Address")
            XCTAssertNotNil(firstRecord["created_at"])
        }
    }
    
    /// Test invalid upgrade
    func testInvalidUpgrade() {
        // Arrange
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let invalidColumns = [
            "id TEXT",  // Changed type
            "name INTEGER",  // Changed type
            "age TEXT",  // Changed type
            "email INTEGER"  // Changed type
        ]
        
        // Create table with old schema
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // Act & Assert
        XCTAssertThrowsError(try db.upgradeTable(
            name: tableName,
            columns: invalidColumns
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let newColumns = TestData.newColumns
        
        // Create table with old schema
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // Act & Assert
        measure {
            _ = try? db.upgradeTable(
                name: tableName,
                columns: newColumns
            )
        }
    }
} 