//
//  MechanismModule_ResponseTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Test class for response mechanism functionality
final class MechanismModule_ResponseTest: CuttDBTestCase {
    /// Test data structure
    struct TestRecord: Codable {
        let id: Int
        let name: String
        let age: Int
    }
    
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER"
        ]
        static let record = TestRecord(id: 1, name: "Test", age: 25)
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try? db.ensureTableExists(tableName: TestData.table, columns: TestData.columns)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic response
    func testBasicResponse() throws {
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
        let records: [TestRecord] = db.query(from: TestData.table, where: "id = ?", parameters: [1])
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].id, TestData.record.id)
        XCTAssertEqual(records[0].name, TestData.record.name)
        XCTAssertEqual(records[0].age, TestData.record.age)
    }
    
    /// Test error response
    func testErrorResponse() throws {
        // 创建测试表
        try db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
        
        // 配置模拟服务抛出错误
        mockService.shouldThrowError = true
        mockService.customError = CuttDBError.databaseError("Test error")
        
        // 尝试插入数据
        XCTAssertThrowsError(try db.insertObject(TestData.record)) { error in
            XCTAssertTrue(error is CuttDBError)
            if case .databaseError(let message) = error as? CuttDBError {
                XCTAssertEqual(message, "Test error")
            }
        }
    }
    
    /// Test validation response
    func testValidationResponse() throws {
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
        
        // 验证数据存在
        let records: [TestRecord] = db.query(from: TestData.table, where: "id = ?", parameters: [1])
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].id, TestData.record.id)
        XCTAssertEqual(records[0].name, TestData.record.name)
        XCTAssertEqual(records[0].age, TestData.record.age)
    }
    
    /// Test transaction response
    func testTransactionResponse() throws {
        // 创建测试表
        try db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
        
        // 在事务中插入数据
        let result = try db.insertObject(TestData.record)
        
        // 验证响应
        XCTAssertNotNil(result)
        XCTAssertTrue(result)
        
        // 验证数据
        let records: [TestRecord] = db.query(from: TestData.table, where: "id = ?", parameters: [1])
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records.count, 1)
        XCTAssertEqual(records[0].id, TestData.record.id)
        XCTAssertEqual(records[0].name, TestData.record.name)
        XCTAssertEqual(records[0].age, TestData.record.age)
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