//
//  AlignModule_CleanupTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation
import XCTest

/// 对齐模块 - 数据清理测试
struct AlignModule_CleanupTest {
    /// 测试数据
    struct Data {
        static let cleanupConfig: [String: Any] = [
            "table_name": "users",
            "conditions": [
                [
                    "field": "status",
                    "operator": "=",
                    "value": "deleted"
                ],
                [
                    "field": "updated_at",
                    "operator": "<",
                    "value": "2023-01-01"
                ]
            ],
            "batch_size": 100,
            "max_retries": 3,
            "retry_delay": 5 // seconds
        ]
        
        static let validationConfig: [String: Any] = [
            "check_constraints": true,
            "check_indexes": true,
            "check_foreign_keys": true,
            "check_triggers": true
        ]
        
        static let backupConfig: [String: Any] = [
            "backup_path": "/backup",
            "backup_format": "sql",
            "compress": true,
            "encrypt": true
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试数据清理
        static func testDataCleanup() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.cleanupData(
                tableName: "users",
                conditions: Data.cleanupConfig["conditions"] as! [[String: Any]],
                dbService: mockDBService
            )
            print("Data Cleanup Result:", result)
            assert(result > 0, "Should cleanup data successfully")
        }
        
        /// 测试批量清理
        static func testBatchCleanup() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.batchCleanup(
                tableName: "users",
                batchSize: 100,
                conditions: Data.cleanupConfig["conditions"] as! [[String: Any]],
                dbService: mockDBService
            )
            print("Batch Cleanup Result:", result)
            assert(result > 0, "Should cleanup data in batches successfully")
        }
        
        /// 测试清理验证
        static func testCleanupValidation() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.validateCleanup(
                tableName: "users",
                config: Data.validationConfig,
                dbService: mockDBService
            )
            print("Cleanup Validation Result:", result)
            assert(result, "Should validate cleanup operation")
        }
        
        /// 测试清理备份
        static func testCleanupBackup() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.backupBeforeCleanup(
                tableName: "users",
                config: Data.backupConfig,
                dbService: mockDBService
            )
            print("Cleanup Backup Result:", result)
            assert(result, "Should backup data before cleanup")
        }
        
        /// 测试清理恢复
        static func testCleanupRestore() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.restoreAfterCleanup(
                tableName: "users",
                backupPath: "/backup/users_backup.sql",
                dbService: mockDBService
            )
            print("Cleanup Restore Result:", result)
            assert(result, "Should restore data after cleanup")
        }
        
        /// 测试清理日志
        static func testCleanupLogging() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.logCleanupOperation(
                tableName: "users",
                operation: "cleanup",
                details: Data.cleanupConfig,
                dbService: mockDBService
            )
            print("Cleanup Logging Result:", result)
            assert(result, "Should log cleanup operation")
        }
    }
}

class AlignModule_CleanupTest: XCTestCase {
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
    
    func testCleanupDuplicates() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "email": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入重复数据
        let duplicateData = [
            ["id": "1", "name": "John", "email": "john@example.com"],
            ["id": "2", "name": "John", "email": "john@example.com"],
            ["id": "3", "name": "Jane", "email": "jane@example.com"]
        ]
        
        for data in duplicateData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 清理重复数据
        let aligner = TableAligner(service: mockService)
        XCTAssertTrue(aligner.cleanupDuplicates(tableName, uniqueColumns: ["name", "email"]))
        
        // 验证结果
        let results = db.queryObjects([String: Any].self, whereClause: "name = 'John'")
        XCTAssertEqual(results.count, 1, "Should only have one record after cleanup")
    }
    
    func testDropMissingData() {
        // 准备测试数据
        let sourceTable = "source_table"
        let targetTable = "target_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT"
        ]
        
        // 创建源表和目标表
        XCTAssertTrue(db.ensureTableExists(tableName: sourceTable, columns: columns))
        XCTAssertTrue(db.ensureTableExists(tableName: targetTable, columns: columns))
        
        // 插入测试数据
        let sourceData = [
            ["id": "1", "name": "John"],
            ["id": "2", "name": "Jane"]
        ]
        
        let targetData = [
            ["id": "1", "name": "John"],
            ["id": "3", "name": "Bob"]
        ]
        
        for data in sourceData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        for data in targetData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 删除缺失数据
        let aligner = TableAligner(service: mockService)
        XCTAssertTrue(aligner.dropMissingData(sourceTable: sourceTable, targetTable: targetTable))
        
        // 验证结果
        let results = db.queryObjects([String: Any].self, whereClause: "name = 'Bob'")
        XCTAssertEqual(results.count, 0, "Should not have Bob's record after cleanup")
    }
    
    func testAlignTable() {
        // 准备测试数据
        let sourceTable = "source_table"
        let targetTable = "target_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "email": "TEXT"
        ]
        
        // 创建源表
        XCTAssertTrue(db.ensureTableExists(tableName: sourceTable, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "email": "john@example.com"],
            ["id": "2", "name": "Jane", "email": "jane@example.com"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 对齐表结构
        let aligner = TableAligner(service: mockService)
        XCTAssertTrue(aligner.alignTable(sourceTable: sourceTable, targetTable: targetTable, columns: columns))
        
        // 验证结果
        let results = db.queryObjects([String: Any].self, whereClause: nil)
        XCTAssertEqual(results.count, 2, "Should have all records after alignment")
    }
} 