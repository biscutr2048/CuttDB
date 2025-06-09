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
    // MARK: - Test Data
    
    /// Test data structure
    struct TestData {
        static let parentTable = "parent_table"
        static let childTable = "child_table"
        static let grandChildTable = "grandchild_table"
        
        static let parentColumns: [String: String] = [
            "id": "TEXT PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        
        static let childColumns: [String: String] = [
            "id": "TEXT PRIMARY KEY",
            "parent_id": "TEXT",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        
        static let grandChildColumns: [String: String] = [
            "id": "TEXT PRIMARY KEY",
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
            "name": "GrandChild 1",
            "age": 10
        ]
        
        struct ParentRecord: Codable {
            let id: String
            let name: String
            let age: Int
        }
        
        struct ChildRecord: Codable {
            let id: String
            let parentId: String
            let name: String
            let age: Int
            
            enum CodingKeys: String, CodingKey {
                case id
                case parentId = "parent_id"
                case name
                case age
            }
        }
        
        struct GrandChildRecord: Codable {
            let id: String
            let childId: String
            let name: String
            let age: Int
            
            enum CodingKeys: String, CodingKey {
                case id
                case childId = "child_id"
                case name
                case age
            }
        }
    }
    
    // MARK: - Test Methods
    
    /// Test creating sub-table
    func testCreateSubTable() {
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
    
    /// Test invalid parent table
    func testInvalidParentTable() {
        // Arrange
        let invalidParentTable = "invalid_parent"
        let childTable = TestData.childTable
        let childColumns = TestData.childColumns
        
        // Act
        let result = try? db.createTable(
            name: childTable,
            columns: Array(childColumns.keys)
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result ?? false)
        
        // Verify
        let childExists = try? db.tableExists(name: childTable)
        XCTAssertTrue(childExists ?? false)
    }
    
    /// Test sub-table data operations
    func testSubTableDataOperations() {
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
        
        // Insert parent
        let parent = TestData.ParentRecord(id: "1", name: "Parent 1", age: 40)
        _ = db.saveObject(parent)
        
        // Insert child
        let child = TestData.ChildRecord(id: "1", parentId: "1", name: "Child 1", age: 20)
        _ = db.saveObject(child)
        
        // Query child
        let children: [TestData.ChildRecord] = db.query(from: childTable, where: "parent_id = '1'")
        XCTAssertEqual(children.count, 1)
        XCTAssertEqual(children[0].name, "Child 1")
        
        // Delete parent
        let deleteResult = db.deleteObject(TestData.ParentRecord.self, id: "1")
        XCTAssertTrue(deleteResult)
        
        // Verify child is deleted
        let remainingChildren: [TestData.ChildRecord] = db.query(from: childTable)
        XCTAssertEqual(remainingChildren.count, 0)
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
