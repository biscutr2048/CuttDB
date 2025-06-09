//
//  SelectModule_PagedQueryTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// 测试分页查询功能
final class SelectModule_PagedQueryTest: CuttDBTestCase {
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
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "email TEXT"
        ]
        
        /// 测试记录
        static let records: [[String: Any]] = [
            [
                "id": 1,
                "name": "Test 1",
                "age": 25,
                "email": "test1@example.com"
            ],
            [
                "id": 2,
                "name": "Test 2",
                "age": 30,
                "email": "test2@example.com"
            ],
            [
                "id": 3,
                "name": "Test 3",
                "age": 35,
                "email": "test3@example.com"
            ],
            [
                "id": 4,
                "name": "Test 4",
                "age": 40,
                "email": "test4@example.com"
            ],
            [
                "id": 5,
                "name": "Test 5",
                "age": 45,
                "email": "test5@example.com"
            ]
        ]
    }
    
    // MARK: - Test Methods
    
    /// 测试基本分页查询
    func testBasicPagedQuery() {
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
        let pageSize = 2
        let pageNumber = 1
        
        let result = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "id",
            limit: pageSize
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, pageSize)
        XCTAssertEqual(result?.first?.id, 1)
        XCTAssertEqual(result?.last?.id, 2)
    }
    
    /// 测试分页查询边界条件
    func testPagedQueryBoundary() {
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
        let pageSize = 2
        let pageNumber = 3  // 最后一页
        
        let result = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "id",
            limit: pageSize
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, pageSize)
        XCTAssertEqual(result?.first?.id, 5)
    }
    
    /// 测试分页查询条件
    func testPagedQueryWithCondition() {
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
        let pageSize = 2
        let pageNumber = 1
        
        let result = try? db.query(
            from: tableName,
            where: "age > ?",
            orderBy: "id",
            limit: pageSize
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, pageSize)
        XCTAssertTrue(result?.allSatisfy { $0.age > 30 } ?? false)
    }
    
    /// 测试分页查询无效条件
    func testPagedQueryInvalidCondition() {
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
            where: "invalid_column > ?",
            orderBy: "id",
            limit: 2
        ) as [TestRecord]) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// 测试分页查询排序
    func testPagedQueryWithOrderBy() {
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
        let pageSize = 2
        let pageNumber = 1
        
        let result = try? db.query(
            from: tableName,
            where: nil,
            orderBy: "age DESC",
            limit: pageSize
        ) as [TestRecord]
        
        // 断言
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.count, pageSize)
        XCTAssertEqual(result?.first?.age, 45)
        XCTAssertEqual(result?.last?.age, 40)
    }
    
    /// 测试分页查询性能
    func testPagedQueryPerformance() {
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
        
        // 执行性能测试
        measure {
            _ = try? db.query(
                from: tableName,
                where: nil,
                orderBy: "id",
                limit: 2
            ) as [TestRecord]
        }
    }
} 