//
//  CreateModule_TableDefinitionTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// 测试表定义功能
final class CreateModule_TableDefinitionTest: CuttDBTestCase {
    // MARK: - Properties
    
    /// 测试数据模型
    private struct TestRecord: Codable {
        let id: Int
        let name: String
        let age: Int
        let email: String
    }
    
    /// 测试数据
    private struct TestData {
        /// 表名
        static let tableName = "test_table"
        
        /// 列定义
        static let columns: [String: String] = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER",
            "email": "TEXT"
        ]
        
        /// 测试记录
        static let testRecord: [String: Any] = [
            "id": 1,
            "name": "Test",
            "age": 25,
            "email": "test@example.com"
        ]
    }
    
    // MARK: - Test Methods
    
    /// 测试基本表定义
    func testBasicTableDefinition() {
        // 准备
        let tableName = TestData.tableName
        let columns = TestData.columns
        
        // 执行
        let result = try? db.createTable(
            name: tableName,
            columns: Array(columns.keys)
        )
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertTrue(result ?? false)
        
        // 验证
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertEqual(tableInfo?.columns.count, columns.count)
        
        for (key, value) in columns {
            XCTAssertTrue(tableInfo?.columns.contains { $0.name == key && $0.type == value } ?? false)
        }
    }
    
    /// 测试表定义验证
    func testTableDefinitionValidation() {
        // 准备
        let tableName = TestData.tableName
        let columns = TestData.columns
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: Array(columns.keys)
        )
        
        // 执行
        let result = db.validateTableStructure(
            tableName: tableName,
            columns: columns
        )
        
        // 断言
        XCTAssertTrue(result)
    }
    
    /// 测试无效表定义
    func testInvalidTableDefinition() {
        // 准备
        let tableName = TestData.tableName
        let invalidColumns = [
            "id": "TEXT",  // 改变类型
            "name": "INTEGER",  // 改变类型
            "age": "TEXT",  // 改变类型
            "email": "INTEGER"  // 改变类型
        ]
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: Array(TestData.columns.keys)
        )
        
        // 执行
        let result = db.validateTableStructure(
            tableName: tableName,
            columns: invalidColumns
        )
        
        // 断言
        XCTAssertFalse(result)
    }
    
    /// 测试表定义与数据操作
    func testTableDefinitionWithData() {
        // 准备
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.testRecord
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: Array(columns.keys)
        )
        
        // 插入数据
        let insertResult = try? db.insertOrUpdate(
            table: tableName,
            record: record
        )
        
        // 断言
        XCTAssertNotNil(insertResult)
        XCTAssertTrue(insertResult?.success ?? false)
        
        // 验证
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertEqual(tableInfo?.columns.count, columns.count)
    }
    
    /// 测试表定义与查询
    func testTableDefinitionWithQuery() {
        // 准备
        let tableName = TestData.tableName
        let columns = TestData.columns
        let record = TestData.testRecord
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: Array(columns.keys)
        )
        
        // 插入数据
        _ = try? db.insertOrUpdate(
            table: tableName,
            record: record
        )
        
        // 执行查询
        let queryResult = try? db.query(
            from: tableName,
            where: "id = ?",
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        
        if let firstRecord = queryResult?.first {
            XCTAssertEqual(firstRecord.id, 1)
            XCTAssertEqual(firstRecord.name, "Test")
            XCTAssertEqual(firstRecord.age, 25)
            XCTAssertEqual(firstRecord.email, "test@example.com")
        }
    }
} 