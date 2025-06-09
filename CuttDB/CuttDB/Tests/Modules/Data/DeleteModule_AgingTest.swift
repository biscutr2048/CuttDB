//
//  DeleteModule_AgingTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// 测试数据老化删除功能
final class DeleteModule_AgingTest: CuttDBTestCase {
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
    
    /// 测试基本老化删除
    func testBasicAgingDelete() {
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
        let oldRecords = try? db.queryList(
            from: tableName,
            where: "created_at < ?",
            orderBy: nil,
            limit: nil
        )
        
        // 删除旧记录
        for record in oldRecords ?? [] {
            if let id = record["id"] as? String {
                _ = db.deleteObject(TestRecord.self, id: id)
            }
        }
        
        // 验证
        let queryResult = try? db.query(
            from: tableName,
            where: nil,
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 2)  // 应该只剩下两条记录
    }
    
    /// 测试老化删除边界条件
    func testAgingDeleteBoundary() {
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
        let oldRecords = try? db.queryList(
            from: tableName,
            where: "created_at <= ?",
            orderBy: nil,
            limit: nil
        )
        
        // 删除旧记录
        for record in oldRecords ?? [] {
            if let id = record["id"] as? String {
                _ = db.deleteObject(TestRecord.self, id: id)
            }
        }
        
        // 验证
        let queryResult = try? db.query(
            from: tableName,
            where: nil,
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)  // 应该只剩下一条记录
    }
    
    /// 测试老化删除多条件
    func testAgingDeleteMultipleConditions() {
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
        let oldRecords = try? db.queryList(
            from: tableName,
            where: "created_at < ? AND age > ?",
            orderBy: nil,
            limit: nil
        )
        
        // 删除旧记录
        for record in oldRecords ?? [] {
            if let id = record["id"] as? String {
                _ = db.deleteObject(TestRecord.self, id: id)
            }
        }
        
        // 验证
        let queryResult = try? db.query(
            from: tableName,
            where: nil,
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 2)  // 应该剩下两条记录
    }
    
    /// 测试老化删除无效条件
    func testAgingDeleteInvalidCondition() {
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
        XCTAssertThrowsError(try db.queryList(
            from: tableName,
            where: "invalid_column < ?",
            orderBy: nil,
            limit: nil
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
} 
