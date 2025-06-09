//
//  DeleteModule_BatchTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for batch delete operations
final class DeleteModule_BatchTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let tableName = "test_table"
        static let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        static let records = [
            ["id": "1", "name": "Test1", "age": 20],
            ["id": "2", "name": "Test2", "age": 30],
            ["id": "3", "name": "Test3", "age": 40],
            ["id": "4", "name": "Test4", "age": 50],
            ["id": "5", "name": "Test5", "age": 60]
        ] as [[String: Any]]
    }
    
    override func setUp() {
        super.setUp()
        
        // Create test table
        try? db.ensureTableExists(
            tableName: TestData.tableName,
            columns: TestData.columns
        )
        
        // Insert test data
        for record in TestData.records {
            try? db.insert(table: TestData.tableName, data: record)
        }
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.tableName)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test batch delete
    func testBatchDelete() {
        // Arrange
        let tableName = TestData.tableName
        let idsToDelete = ["1", "3", "5"]
        
        // Act
        let idList = idsToDelete.map { "'\($0)'" }.joined(separator: ", ")
        let sql = "DELETE FROM \(tableName) WHERE id IN (\(idList))"
        let result = try? db.queryList(from: tableName, where: sql)
        
        // Assert
        XCTAssertNotNil(result)
        
        // Verify
        let remainingRecords = try? db.queryList(from: tableName)
        XCTAssertNotNil(remainingRecords)
        XCTAssertEqual(remainingRecords?.count, 2)
        
        let remainingIds = remainingRecords?.compactMap { $0["id"] as? String }
        XCTAssertEqual(Set(remainingIds ?? []), Set(["2", "4"]))
    }
} 
