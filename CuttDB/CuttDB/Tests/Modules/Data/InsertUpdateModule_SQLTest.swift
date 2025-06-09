//
//  InsertUpdateModule_SQLTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// 测试 SQL 操作功能
final class InsertUpdateModule_SQLTest: CuttDBTestCase {
    // MARK: - Properties
    
    /// 测试数据模型
    private struct TestRecord: Codable {
        let id: Int
        let name: String
        let value: String
    }
    
    /// 测试数据
    private struct TestData {
        /// 表名
        static let tableName = "test_table"
        
        /// 列定义
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "value TEXT"
        ]
        
        /// 测试记录
        static let records: [[String: Any]] = [
            [
                "id": 1,
                "name": "Test 1",
                "value": "Value 1"
            ],
            [
                "id": 2,
                "name": "Test 2",
                "value": "Value 2"
            ]
        ]
    }
    
    // MARK: - Test Methods
    
    /// 测试 SQL 操作
    func testSQLOperations() {
        // 准备
        let tableName = TestData.tableName
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // 插入测试数据
        for record in TestData.records {
            let result = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
            XCTAssertTrue(result?.success ?? false)
        }
        
        // 测试无效的 SQL 操作
        let invalidQuery = try? db.query(
            from: tableName,
            where: "invalid_column = ?",
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        XCTAssertNil(invalidQuery)
        
        // 测试更新操作
        let updateRecord: [String: Any] = [
            "id": 1,
            "name": "Updated Test",
            "value": "Updated Value"
        ]
        
        let updateResult = try? db.insertOrUpdate(
            table: tableName,
            record: updateRecord
        )
        XCTAssertTrue(updateResult?.success ?? false)
        
        // 验证更新结果
        let queryResult = try? db.query(
            from: tableName,
            where: "id = 1",
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        XCTAssertEqual(queryResult?.first?.name, "Updated Test")
        XCTAssertEqual(queryResult?.first?.value, "Updated Value")
    }
    
    /// 测试批量 SQL 操作
    func testBatchSQLOperations() {
        // 准备
        let tableName = TestData.tableName
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // 批量插入测试数据
        for record in TestData.records {
            let result = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
            XCTAssertTrue(result?.success ?? false)
        }
        
        // 验证批量插入结果
        let queryResult = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, TestData.records.count)
        
        // 验证记录内容
        for (index, record) in (queryResult ?? []).enumerated() {
            let expectedRecord = TestData.records[index]
            XCTAssertEqual(record.id, expectedRecord["id"] as? Int)
            XCTAssertEqual(record.name, expectedRecord["name"] as? String)
            XCTAssertEqual(record.value, expectedRecord["value"] as? String)
        }
    }
    
    /// 测试 SQL 操作错误处理
    func testSQLErrorHandling() {
        // 准备
        let tableName = TestData.tableName
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // 测试无效的表名
        let invalidTableQuery = try? db.query(
            from: "invalid_table",
            where: nil,
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        XCTAssertNil(invalidTableQuery)
        
        // 测试无效的列名
        let invalidRecord: [String: Any] = [
            "id": 1,
            "invalid_column": "value"
        ]
        
        let invalidColumnResult = try? db.insertOrUpdate(
            table: tableName,
            record: invalidRecord
        )
        XCTAssertFalse(invalidColumnResult?.success ?? true)
    }
} 
