//
//  CreateModule_SubTableTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for sub-table functionality
final class CreateModule_SubTableTest: CuttDBTestCase {
    // MARK: - Properties
    
    /// Test data structure
    struct TestData {
        static let parentTable = "parent_table"
        static let childTable = "child_table"
        static let grandChildTable = "grandchild_table"
        
        static let parentColumns = [
            "id": "TEXT",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        
        static let childColumns = [
            "id": "TEXT",
            "parent_id": "TEXT",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        
        static let grandChildColumns = [
            "id": "TEXT",
            "child_id": "TEXT",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        
        static let parentRecord: [String: Any] = [
            "id": "1",
            "name": "Parent 1",
            "age": 40
        ]
        
        static let childRecord: [String: Any] = [
            "id": "1",
            "parent_id": "1",
            "name": "Child 1",
            "age": 20
        ]
        
        static let grandChildRecord: [String: Any] = [
            "id": "1",
            "child_id": "1",
            "name": "Grandchild 1",
            "age": 10
        ]
        
        struct ParentRecord: Codable {
            let id: String
            let name: String
            let age: Int
        }
    }
    
    // MARK: - Setup and Teardown
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.grandChildTable)
        try? db.dropTable(name: TestData.childTable)
        try? db.dropTable(name: TestData.parentTable)
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
            columns: Array(parentColumns.keys)
        )
        let childResult = try? db.createTable(
            name: childTable,
            columns: Array(childColumns.keys)
        )
        
        // Assert
        XCTAssertNotNil(parentResult)
        XCTAssertTrue(parentResult ?? false)
        XCTAssertNotNil(childResult)
        XCTAssertTrue(childResult ?? false)
        
        // Verify
        let parentExists = try? db.tableExists(name: parentTable)
        XCTAssertTrue(parentExists ?? false)
        let childExists = try? db.tableExists(name: childTable)
        XCTAssertTrue(childExists ?? false)
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
            columns: Array(parentColumns.keys)
        )
        _ = try? db.createTable(
            name: childTable,
            columns: Array(childColumns.keys)
        )
        
        // Create and save parent record
        let parent = TestData.ParentRecord(id: "1", name: "Parent 1", age: 40)
        _ = db.saveObject(parent)
        
        // Insert child record
        _ = try? db.insert(
            table: childTable,
            data: TestData.childRecord
        )
        
        // Act
        let deleteResult = db.deleteObject(TestData.ParentRecord.self, id: "1")
        
        // Assert
        XCTAssertTrue(deleteResult)
        
        // Verify child records are deleted
        let childRecords = db.queryList(from: childTable)
        XCTAssertEqual(childRecords.count, 0)
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
            columns: Array(parentColumns.keys)
        )
        _ = try? db.createTable(
            name: childTable,
            columns: Array(childColumns.keys)
        )
        
        // Act & Assert - Try to insert child without parent
        let insertResult = try? db.insert(
            table: childTable,
            data: TestData.childRecord
        )
        XCTAssertFalse(insertResult ?? true)
        
        // Insert parent first
        let parent = TestData.ParentRecord(id: "1", name: "Parent 1", age: 40)
        _ = db.saveObject(parent)
        
        // Now try to insert child
        let result = try? db.insert(
            table: childTable,
            data: TestData.childRecord
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result ?? false)
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
            columns: Array(parentColumns.keys)
        )
        let childResult = try? db.createTable(
            name: childTable,
            columns: Array(childColumns.keys)
        )
        let grandChildResult = try? db.createTable(
            name: grandChildTable,
            columns: Array(grandChildColumns.keys)
        )
        
        // Assert
        XCTAssertNotNil(parentResult)
        XCTAssertTrue(parentResult ?? false)
        XCTAssertNotNil(childResult)
        XCTAssertTrue(childResult ?? false)
        XCTAssertNotNil(grandChildResult)
        XCTAssertTrue(grandChildResult ?? false)
        
        // Verify
        let parentExists = try? db.tableExists(name: parentTable)
        XCTAssertTrue(parentExists ?? false)
        let childExists = try? db.tableExists(name: childTable)
        XCTAssertTrue(childExists ?? false)
        let grandChildExists = try? db.tableExists(name: grandChildTable)
        XCTAssertTrue(grandChildExists ?? false)
    }
} 
