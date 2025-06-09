//
//  AlignModule_CleanupTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// 测试数据清理功能
final class AlignModule_CleanupTest: CuttDBTestCase {
    // MARK: - Properties
    
    /// 测试数据模型
    private struct TestRecord: Codable {
        let id: Int
        let name: String
        let age: Int
        let created_at: Double
    }
    
    /// 测试数据
    private struct TestData {
        /// 表名
        static let tableName = "test_table"
        
        /// 列定义
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "created_at INTEGER"
        ]
        
        /// 测试记录
        static let records: [[String: Any]] = [
            [
                "id": 1,
                "name": "Old Record 1",
                "age": 25,
                "created_at": Date().timeIntervalSince1970 - 86400 * 31  // 31天前
            ],
            [
                "id": 2,
                "name": "Old Record 2",
                "age": 30,
                "created_at": Date().timeIntervalSince1970 - 86400 * 15  // 15天前
            ],
            [
                "id": 3,
                "name": "New Record",
                "age": 35,
                "created_at": Date().timeIntervalSince1970  // 现在
            ]
        ]
    }
    
    // MARK: - Test Methods
    
    /// 测试基本清理功能
    func testBasicCleanup() {
        // 准备
        let tableName = TestData.tableName
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // 插入测试数据
        for record in TestData.records {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
        
        // 执行
        let result = try? db.query(
            from: tableName,
            where: "created_at < ?",
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)  // 应该找到两条旧记录
        
        // 删除旧记录
        for record in result ?? [] {
            _ = db.deleteObject(TestRecord.self, id: String(record.id))
        }
        
        // 验证
        let remainingRecords = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(remainingRecords)
        XCTAssertEqual(remainingRecords?.count, 1)  // 应该只剩下一条新记录
        XCTAssertEqual(remainingRecords?.first?.id, 3)  // 应该是 ID 为 3 的记录
    }
    
    /// 测试清理边界条件
    func testCleanupBoundary() {
        // 准备
        let tableName = TestData.tableName
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // 插入测试数据
        for record in TestData.records {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
        
        // 执行
        let result = try? db.query(
            from: tableName,
            where: "created_at <= ?",
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 3)  // 应该找到所有记录
        
        // 删除旧记录
        for record in result ?? [] {
            _ = db.deleteObject(TestRecord.self, id: String(record.id))
        }
        
        // 验证
        let remainingRecords = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(remainingRecords)
        XCTAssertEqual(remainingRecords?.count, 0)  // 应该没有剩余记录
    }
    
    /// 测试清理多条件
    func testCleanupMultipleConditions() {
        // 准备
        let tableName = TestData.tableName
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // 插入测试数据
        for record in TestData.records {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
        
        // 执行
        let result = try? db.query(
            from: tableName,
            where: "created_at < ? AND age > ?",
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, 2)  // 应该找到两条符合条件的记录
        
        // 删除旧记录
        for record in result ?? [] {
            _ = db.deleteObject(TestRecord.self, id: String(record.id))
        }
        
        // 验证
        let remainingRecords = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "id",
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(remainingRecords)
        XCTAssertEqual(remainingRecords?.count, 1)  // 应该只剩下一条记录
        XCTAssertEqual(remainingRecords?.first?.id, 3)  // 应该是 ID 为 3 的记录
    }
    
    /// 测试清理无效条件
    func testCleanupInvalidCondition() {
        // 准备
        let tableName = TestData.tableName
        
        // 创建表
        _ = try? db.createTable(
            name: tableName,
            columns: TestData.columns
        )
        
        // 插入测试数据
        for record in TestData.records {
            _ = try? db.insertOrUpdate(
                table: tableName,
                record: record
            )
        }
        
        // 执行和断言
        XCTAssertThrowsError(try db.query(
            from: tableName,
            where: "invalid_column < ?",
            orderBy: "id",
            limit: nil
        ) as [TestRecord]) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
} 