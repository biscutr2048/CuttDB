//
//  AlignModule_UpgradeTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// 测试数据库升级功能
final class AlignModule_UpgradeTest: CuttDBTestCase {
    // MARK: - Properties
    
    /// 测试数据模型
    private struct TestRecord: Codable {
        let id: Int
        let name: String
        let age: Int
        let email: String
        let phone: String?
        let address: String?
        let created_at: Double?
    }
    
    /// 测试数据
    private struct TestData {
        /// 表名
        static let tableName = "test_table"
        
        /// 旧列定义
        static let oldColumns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "email TEXT"
        ]
        
        /// 新列定义
        static let newColumns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "email TEXT",
            "phone TEXT",
            "address TEXT",
            "created_at INTEGER"
        ]
        
        /// 旧记录
        static let oldRecord: [String: Any] = [
            "id": 1,
            "name": "Test",
            "age": 25,
            "email": "test@example.com"
        ]
        
        /// 新记录
        static let newRecord: [String: Any] = [
            "id": 1,
            "name": "Test",
            "age": 25,
            "email": "test@example.com",
            "phone": "123456",
            "address": "Test Address",
            "created_at": Date().timeIntervalSince1970
        ]
    }
    
    // MARK: - Test Methods
    
    /// 测试基本表升级
    func testBasicTableUpgrade() {
        // 准备
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let newColumns = TestData.newColumns
        
        // 创建旧表
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // 插入旧记录
        _ = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.oldRecord
        )
        
        // 执行
        let result = try? db.createTable(
            name: tableName,
            columns: newColumns
        )
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertTrue(result ?? false)
        
        // 验证
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "phone" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "address" } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "created_at" } ?? false)
    }
    
    /// 测试升级时数据保留
    func testDataPreservation() {
        // 准备
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let newColumns = TestData.newColumns
        
        // 创建旧表
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // 插入旧记录
        _ = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.oldRecord
        )
        
        // 执行
        _ = try? db.createTable(
            name: tableName,
            columns: newColumns
        )
        
        // 验证
        let queryResult = try? db.query(
            from: tableName,
            where: "id = ?",
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        
        if let firstRecord = queryResult?.first {
            XCTAssertEqual(firstRecord.id, 1)
            XCTAssertEqual(firstRecord.name, "Test")
            XCTAssertEqual(firstRecord.age, 25)
            XCTAssertEqual(firstRecord.email, "test@example.com")
        }
    }
    
    /// 测试升级后插入新数据
    func testUpgradeWithNewData() {
        // 准备
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let newColumns = TestData.newColumns
        
        // 创建旧表
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // 插入旧记录
        _ = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.oldRecord
        )
        
        // 升级表
        _ = try? db.createTable(
            name: tableName,
            columns: newColumns
        )
        
        // 执行
        let result = try? db.insertOrUpdate(
            table: tableName,
            record: TestData.newRecord
        )
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // 验证
        let queryResult = try? db.query(
            from: tableName,
            where: "id = ?",
            orderBy: nil,
            limit: nil
        ) as [TestRecord]
        XCTAssertNotNil(queryResult)
        XCTAssertEqual(queryResult?.count, 1)
        
        if let firstRecord = queryResult?.first {
            XCTAssertEqual(firstRecord.phone, "123456")
            XCTAssertEqual(firstRecord.address, "Test Address")
            XCTAssertNotNil(firstRecord.created_at)
        }
    }
    
    /// 测试无效升级
    func testInvalidUpgrade() {
        // 准备
        let tableName = TestData.tableName
        let oldColumns = TestData.oldColumns
        let invalidColumns = [
            "id TEXT",  // 改变类型
            "name INTEGER",  // 改变类型
            "age TEXT",  // 改变类型
            "email INTEGER"  // 改变类型
        ]
        
        // 创建旧表
        _ = try? db.createTable(
            name: tableName,
            columns: oldColumns
        )
        
        // 执行和断言
        XCTAssertThrowsError(try db.createTable(
            name: tableName,
            columns: invalidColumns
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
} 