//
//  CreateModule_SubTableTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for sub-table functionality
final class CreateModule_SubTableTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let parentTable = "parent_table"
        static let childTable = "child_table"
        static let grandChildTable = "grandchild_table"
        
        static let parentColumns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "created_at INTEGER"
        ]
        
        static let childColumns = [
            "id INTEGER PRIMARY KEY",
            "parent_id INTEGER",
            "name TEXT",
            "created_at INTEGER",
            "FOREIGN KEY(parent_id) REFERENCES parent_table(id)"
        ]
        
        static let grandChildColumns = [
            "id INTEGER PRIMARY KEY",
            "child_id INTEGER",
            "name TEXT",
            "created_at INTEGER",
            "FOREIGN KEY(child_id) REFERENCES child_table(id)"
        ]
        
        static let parentRecord: [String: Any] = [
            "id": 1,
            "name": "Parent",
            "created_at": Date().timeIntervalSince1970
        ]
        
        static let childRecord: [String: Any] = [
            "id": 1,
            "parent_id": 1,
            "name": "Child",
            "created_at": Date().timeIntervalSince1970
        ]
        
        static let grandChildRecord: [String: Any] = [
            "id": 1,
            "child_id": 1,
            "name": "GrandChild",
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
        try? db.dropTable(name: TestData.grandChildTable)
        try? db.dropTable(name: TestData.childTable)
        try? db.dropTable(name: TestData.parentTable)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic sub-table creation
    func testBasicSubTableCreation() {
        // Arrange
        let parentTable = TestData.parentTable
        let childTable = TestData.childTable
        let parentColumns = TestData.parentColumns
        let childColumns = TestData.childColumns
        
        // Act
        let parentResult = try? db.createTable(
            name: parentTable,
            columns: parentColumns
        )
        let childResult = try? db.createTable(
            name: childTable,
            columns: childColumns
        )
        
        // Assert
        XCTAssertNotNil(parentResult)
        XCTAssertTrue(parentResult?.success ?? false)
        XCTAssertNotNil(childResult)
        XCTAssertTrue(childResult?.success ?? false)
        
        // Verify
        let parentExists = try? db.tableExists(name: parentTable)
        XCTAssertTrue(parentExists ?? false)
        let childExists = try? db.tableExists(name: childTable)
        XCTAssertTrue(childExists ?? false)
    }
    
    /// Test nested sub-table creation
    func testNestedSubTableCreation() {
        // Arrange
        let parentTable = TestData.parentTable
        let childTable = TestData.childTable
        let grandChildTable = TestData.grandChildTable
        let parentColumns = TestData.parentColumns
        let childColumns = TestData.childColumns
        let grandChildColumns = TestData.grandChildColumns
        
        // Act
        let parentResult = try? db.createTable(
            name: parentTable,
            columns: parentColumns
        )
        let childResult = try? db.createTable(
            name: childTable,
            columns: childColumns
        )
        let grandChildResult = try? db.createTable(
            name: grandChildTable,
            columns: grandChildColumns
        )
        
        // Assert
        XCTAssertNotNil(parentResult)
        XCTAssertTrue(parentResult?.success ?? false)
        XCTAssertNotNil(childResult)
        XCTAssertTrue(childResult?.success ?? false)
        XCTAssertNotNil(grandChildResult)
        XCTAssertTrue(grandChildResult?.success ?? false)
        
        // Verify
        let parentExists = try? db.tableExists(name: parentTable)
        XCTAssertTrue(parentExists ?? false)
        let childExists = try? db.tableExists(name: childTable)
        XCTAssertTrue(childExists ?? false)
        let grandChildExists = try? db.tableExists(name: grandChildTable)
        XCTAssertTrue(grandChildExists ?? false)
    }
    
    /// Test foreign key constraints
    func testForeignKeyConstraints() {
        // Arrange
        let parentTable = TestData.parentTable
        let childTable = TestData.childTable
        let parentColumns = TestData.parentColumns
        let childColumns = TestData.childColumns
        
        // Create tables
        _ = try? db.createTable(
            name: parentTable,
            columns: parentColumns
        )
        _ = try? db.createTable(
            name: childTable,
            columns: childColumns
        )
        
        // Act & Assert - Try to insert child without parent
        XCTAssertThrowsError(try db.insertOrUpdate(
            table: childTable,
            record: TestData.childRecord
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
        
        // Insert parent first
        _ = try? db.insertOrUpdate(
            table: parentTable,
            record: TestData.parentRecord
        )
        
        // Now try to insert child
        let result = try? db.insertOrUpdate(
            table: childTable,
            record: TestData.childRecord
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
    }
    
    /// Test cascade delete
    func testCascadeDelete() {
        // Arrange
        let parentTable = TestData.parentTable
        let childTable = TestData.childTable
        let parentColumns = TestData.parentColumns
        let childColumns = TestData.childColumns
        
        // Create tables
        _ = try? db.createTable(
            name: parentTable,
            columns: parentColumns
        )
        _ = try? db.createTable(
            name: childTable,
            columns: childColumns
        )
        
        // Insert records
        _ = try? db.insertOrUpdate(
            table: parentTable,
            record: TestData.parentRecord
        )
        _ = try? db.insertOrUpdate(
            table: childTable,
            record: TestData.childRecord
        )
        
        // Act
        let deleteResult = try? db.delete(
            table: parentTable,
            where: "id = ?",
            params: [1]
        )
        
        // Assert
        XCTAssertNotNil(deleteResult)
        XCTAssertTrue(deleteResult?.success ?? false)
        
        // Verify child is also deleted
        let childCount = try? db.count(
            table: childTable,
            where: "parent_id = ?",
            params: [1]
        )
        XCTAssertEqual(childCount, 0)
    }
    
    /// Test invalid foreign key
    func testInvalidForeignKey() {
        // Arrange
        let parentTable = TestData.parentTable
        let childTable = TestData.childTable
        let parentColumns = TestData.parentColumns
        let invalidChildColumns = [
            "id INTEGER PRIMARY KEY",
            "parent_id INTEGER",
            "name TEXT",
            "created_at INTEGER",
            "FOREIGN KEY(parent_id) REFERENCES non_existent_table(id)"
        ]
        
        // Create parent table
        _ = try? db.createTable(
            name: parentTable,
            columns: parentColumns
        )
        
        // Act & Assert
        XCTAssertThrowsError(try db.createTable(
            name: childTable,
            columns: invalidChildColumns
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let parentTable = TestData.parentTable
        let childTable = TestData.childTable
        let parentColumns = TestData.parentColumns
        let childColumns = TestData.childColumns
        
        // Act & Assert
        measure {
            _ = try? db.createTable(
                name: parentTable,
                columns: parentColumns
            )
            _ = try? db.createTable(
                name: childTable,
                columns: childColumns
            )
        }
    }
} 