//
//  ListPropertiesModule_ComplexTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for complex list properties operations
final class ListPropertiesModule_ComplexTest: CuttDBTestCase {
    // MARK: - Properties
    
    /// Test data model
    private struct TestRecord: Codable {
        let id: Int
        let name: String
        let tags: [String]
        let scores: [Int]
    }
    
    /// Test data
    private struct TestData {
        /// Table name
        static let tableName = "test_table"
        
        /// Column definitions
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "tags TEXT",
            "scores TEXT"
        ]
        
        /// Test records
        static let records: [[String: Any]] = [
            [
                "id": 1,
                "name": "Test 1",
                "tags": ["tag1", "tag2"],
                "scores": [80, 90]
            ],
            [
                "id": 2,
                "name": "Test 2",
                "tags": ["tag2", "tag3"],
                "scores": [85, 95]
            ]
        ]
    }
    
    // MARK: - Test Methods
    
    /// Test basic list properties
    func testBasicListProperties() {
        // Prepare
        let tableName = TestData.tableName
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // Insert test data
        for record in TestData.records {
            let result = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
            XCTAssertTrue(result?.success ?? false)
        }
        
        // Query and verify
        let queryResult = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, TestData.records.count)
        
        // Verify first record
        if let firstRecord = queryResult?.first {
            XCTAssertEqual(firstRecord.id, 1)
            XCTAssertEqual(firstRecord.name, "Test 1")
            XCTAssertEqual(firstRecord.tags, ["tag1", "tag2"])
            XCTAssertEqual(firstRecord.scores, [80, 90])
        }
    }
    
    /// Test list properties update
    func testListPropertiesUpdate() {
        // Prepare
        let tableName = TestData.tableName
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // Insert test data
        for record in TestData.records {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
        
        // Update record
        let updateRecord: [String: Any] = [
            "id": 1,
            "name": "Updated Test",
            "tags": ["new_tag1", "new_tag2"],
            "scores": [95, 100]
        ]
        
        let updateResult = try? db.insertOrUpdate(
            table: tableName,
            record: updateRecord
        )
        XCTAssertTrue(updateResult?.success ?? false)
        
        // Verify update result
        let queryResult = try? db.query(
            from: tableName,
            where: "id = ?",
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        
        if let updatedRecord = queryResult?.first {
            XCTAssertEqual(updatedRecord.id, 1)
            XCTAssertEqual(updatedRecord.name, "Updated Test")
            XCTAssertEqual(updatedRecord.tags, ["new_tag1", "new_tag2"])
            XCTAssertEqual(updatedRecord.scores, [95, 100])
        }
    }
    
    /// Test list properties query
    func testListPropertiesQuery() {
        // Prepare
        let tableName = TestData.tableName
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // Insert test data
        for record in TestData.records {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
        
        // Query for records containing specific tags
        let queryResult = try? db.query(
            from: tableName,
            where: "tags LIKE ?",
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 2)  // Both records contain "tag2"
        
        // Verify query result
        for record in queryResult ?? [] {
            XCTAssertTrue(record.tags.contains("tag2"))
        }
    }
    
    /// Test list properties error handling
    func testListPropertiesErrorHandling() {
        // Prepare
        let tableName = TestData.tableName
        
        // Create table
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // Test invalid list data
        let invalidRecord: [String: Any] = [
            "id": 1,
            "name": "Invalid Test",
            "tags": "not_an_array",  // Should be an array
            "scores": [1, 2, 3]
        ]
        
        XCTAssertThrowsError(try db.insertOrUpdate(
            table: tableName,
            record: invalidRecord
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
} 
