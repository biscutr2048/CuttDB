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
    struct TestRecord: Codable, Equatable {
        let id: Int
        let name: String
        let age: Int
        let tags: String
    }
    let table = "list_properties_test"
    
    override func setUp() {
        super.setUp()
        _ = db.ensureTableExists(tableName: table, columns: [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER",
            "tags": "TEXT"
        ])
    }
    
    override func tearDown() {
        // 通常测试用例不需要 dropTable，直接保证表存在即可
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic list properties
    func testBasicListProperties() throws {
        let record = TestRecord(id: 1, name: "Test", age: 25, tags: "tag1,tag2,tag3")
        let result = db.insertObject(record)
        XCTAssertTrue(result)
        let records: [TestRecord] = db.query(from: table, where: "id = 1")
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0], record)
    }
    
    /// Test list properties with multiple values
    func testListPropertiesWithMultipleValues() throws {
        let records = [
            TestRecord(id: 1, name: "Test 1", age: 25, tags: "tag1,tag2"),
            TestRecord(id: 2, name: "Test 2", age: 30, tags: "tag2,tag3"),
            TestRecord(id: 3, name: "Test 3", age: 35, tags: "tag1,tag3")
        ]
        for rec in records {
            XCTAssertTrue(db.insertObject(rec))
        }
        let results: [TestRecord] = db.query(from: table)
        XCTAssertEqual(results.count, 3)
    }
    
    /// Test list properties with invalid data
    func testListPropertiesWithInvalidData() throws {
        struct InvalidRecord: Codable {
            let id: String
            let name: Int
            let age: String
            let tags: Int
        }
        let invalid = InvalidRecord(id: "bad", name: 123, age: "not a number", tags: 456)
        let result = db.insertObject(invalid)
        XCTAssertFalse(result)
    }
    
    /// Test performance
    func testPerformance() throws {
        let record = TestRecord(id: 99, name: "Perf", age: 1, tags: "t")
        self.measure {
            _ = db.insertObject(record)
        }
    }
} 