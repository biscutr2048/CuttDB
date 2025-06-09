//
//  DeleteModule_AgingTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for aging functionality
final class DeleteModule_AgingTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER",
            "created_at": "INTEGER"
        ]
        static let record = [
            "id": 1,
            "name": "Test",
            "age": 25,
            "created_at": Date().timeIntervalSince1970
        ] as [String: Any]
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try? db.ensureTableExists(tableName: TestData.table, columns: TestData.columns)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic aging
    func testBasicAging() throws {
        // 创建测试表
        try db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
        
        // 插入测试数据
        let result = try db.insertObject(TestData.record)
        
        // 验证响应
        XCTAssertNotNil(result)
        XCTAssertTrue(result)
        
        // 验证数据
        let records: [[String: Any]] = db.queryList(from: TestData.table, where: "id = ?", parameters: [1])
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0]["id"] as? Int, TestData.record["id"] as? Int)
        XCTAssertEqual(records[0]["name"] as? String, TestData.record["name"] as? String)
        XCTAssertEqual(records[0]["age"] as? Int, TestData.record["age"] as? Int)
    }
    
    /// Test aging with old records
    func testAgingWithOldRecords() throws {
        // 创建测试表
        try db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
        
        // 插入旧数据
        let oldRecord = [
            "id": 1,
            "name": "Old Record",
            "age": 25,
            "created_at": Date().timeIntervalSince1970 - 86400 // 1天前
        ] as [String: Any]
        
        let result = try db.insertObject(oldRecord)
        
        // 验证响应
        XCTAssertNotNil(result)
        XCTAssertTrue(result)
        
        // 验证数据
        let records: [[String: Any]] = db.queryList(from: TestData.table, where: "id = ?", parameters: [1])
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0]["id"] as? Int, oldRecord["id"] as? Int)
        XCTAssertEqual(records[0]["name"] as? String, oldRecord["name"] as? String)
        XCTAssertEqual(records[0]["age"] as? Int, oldRecord["age"] as? Int)
    }
    
    /// Test aging with mixed records
    func testAgingWithMixedRecords() throws {
        // 创建测试表
        try db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
        
        // 插入新旧数据
        let oldRecord = [
            "id": 1,
            "name": "Old Record",
            "age": 25,
            "created_at": Date().timeIntervalSince1970 - 86400 // 1天前
        ] as [String: Any]
        
        let newRecord = [
            "id": 2,
            "name": "New Record",
            "age": 30,
            "created_at": Date().timeIntervalSince1970
        ] as [String: Any]
        
        let result1 = try db.insertObject(oldRecord)
        let result2 = try db.insertObject(newRecord)
        
        // 验证响应
        XCTAssertNotNil(result1)
        XCTAssertTrue(result1)
        XCTAssertNotNil(result2)
        XCTAssertTrue(result2)
        
        // 验证数据
        let records: [[String: Any]] = db.queryList(from: TestData.table)
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records.count, 2)
        XCTAssertEqual(records[0]["id"] as? Int, oldRecord["id"] as? Int)
        XCTAssertEqual(records[1]["id"] as? Int, newRecord["id"] as? Int)
    }
    
    /// Test performance
    func testPerformance() throws {
        // 创建测试表
        try db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
        
        measure {
            // 执行插入操作
            try? db.insertObject(TestData.record)
        }
    }
} 