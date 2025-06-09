//
//  AlignModule_UpgradeTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation
import XCTest
@testable import CuttDB

class AlignModule_UpgradeTest: XCTestCase {
    private var db: CuttDB!
    private var mockService: MockCuttDBService!
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
    }
    
    override func tearDown() {
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    func testUpgradeTableStructure() {
        // 准备测试数据
        let tableName = "test_table"
        let oldColumns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT"
        ]
        
        let newColumns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "email": "TEXT",
            "age": "INTEGER"
        ]
        
        // 创建旧表结构
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: oldColumns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John"],
            ["id": "2", "name": "Jane"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 升级表结构
        let aligner = TableAligner(service: mockService)
        XCTAssertTrue(aligner.upgradeTableStructure(tableName: tableName, newColumns: newColumns))
        
        // 验证结果
        let results = db.queryObjects([String: Any].self, whereClause: nil)
        XCTAssertEqual(results.count, 2, "Should have all records after upgrade")
        
        // 验证新列是否存在
        let firstRecord = results.first
        XCTAssertNotNil(firstRecord?["email"], "New column 'email' should exist")
        XCTAssertNotNil(firstRecord?["age"], "New column 'age' should exist")
    }
    
    func testAddColumn() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John"],
            ["id": "2", "name": "Jane"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 添加新列
        let aligner = TableAligner(service: mockService)
        XCTAssertTrue(aligner.addColumn(tableName: tableName, columnName: "email", columnType: "TEXT"))
        
        // 验证结果
        let results = db.queryObjects([String: Any].self, whereClause: nil)
        XCTAssertEqual(results.count, 2, "Should have all records after adding column")
        
        // 验证新列是否存在
        let firstRecord = results.first
        XCTAssertNotNil(firstRecord?["email"], "New column 'email' should exist")
    }
    
    func testModifyColumn() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "age": "INTEGER"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "age": "25"],
            ["id": "2", "age": "30"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 修改列类型
        let aligner = TableAligner(service: mockService)
        XCTAssertTrue(aligner.modifyColumn(tableName: tableName, columnName: "age", newType: "REAL"))
        
        // 验证结果
        let results = db.queryObjects([String: Any].self, whereClause: nil)
        XCTAssertEqual(results.count, 2, "Should have all records after modifying column")
        
        // 验证列类型是否已修改
        let firstRecord = results.first
        XCTAssertNotNil(firstRecord?["age"], "Column 'age' should exist with new type")
    }
    
    func testDropColumn() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "email": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "email": "john@example.com"],
            ["id": "2", "name": "Jane", "email": "jane@example.com"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 删除列
        let aligner = TableAligner(service: mockService)
        XCTAssertTrue(aligner.dropColumn(tableName: tableName, columnName: "email"))
        
        // 验证结果
        let results = db.queryObjects([String: Any].self, whereClause: nil)
        XCTAssertEqual(results.count, 2, "Should have all records after dropping column")
        
        // 验证列是否已删除
        let firstRecord = results.first
        XCTAssertNil(firstRecord?["email"], "Column 'email' should not exist")
    }
} 