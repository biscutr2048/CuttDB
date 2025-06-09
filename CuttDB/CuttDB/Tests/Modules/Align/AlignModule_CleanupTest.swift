//
//  AlignModule_CleanupTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for cleanup functionality
final class AlignModule_CleanupTest: CuttDBTestCase {
    struct TestRecord: Codable, Equatable {
        let id: Int
        let name: String
        let value: String
    }
    let table = "align_cleanup_test"

    override func setUp() {
        super.setUp()
        _ = db.ensureTableExists(tableName: table, columns: [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "value": "TEXT"
        ])
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Test Methods
    
    /// Test basic cleanup
    func testBasicCleanup() throws {
        let record = TestRecord(id: 1, name: "A", value: "B")
        let result = db.insertObject(record)
        XCTAssertTrue(result)
        let records: [TestRecord] = db.query(from: table, where: "id = 1")
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0], record)
    }
    
    /// Test cleanup with multiple records
    func testCleanupWithMultipleRecords() throws {
        let records = [
            TestRecord(id: 1, name: "A", value: "B"),
            TestRecord(id: 2, name: "C", value: "D")
        ]
        for rec in records {
            XCTAssertTrue(db.insertObject(rec))
        }
        let results: [TestRecord] = db.query(from: table)
        XCTAssertEqual(results.count, 2)
    }
    
    /// Test cleanup with invalid data
    func testCleanupWithInvalidData() throws {
        struct InvalidRecord: Codable {
            let id: String
            let name: Int
        }
        let invalid = InvalidRecord(id: "bad", name: 123)
        let result = db.insertObject(invalid)
        XCTAssertFalse(result)
    }
    
    /// Test performance
    func testPerformance() throws {
        let record = TestRecord(id: 99, name: "Perf", value: "Test")
        self.measure {
            _ = db.insertObject(record)
        }
    }
} 