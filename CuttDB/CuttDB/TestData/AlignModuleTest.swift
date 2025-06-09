import Foundation

/// 对齐模块测试
struct AlignModuleTest {
    /// 测试数据
    struct Data {
        static let sourceTableSchema: [String: String] = [
            "id": "INTEGER",
            "name": "TEXT",
            "email": "TEXT",
            "created_at": "TEXT",
            "status": "TEXT"
        ]
        
        static let destTableSchema: [String: String] = [
            "id": "INTEGER",
            "name": "TEXT",
            "email": "TEXT"
        ]
        
        static let missingData: [[String: Any]] = [
            [
                "id": 1,
                "name": "Test 1",
                "email": "test1@example.com"
            ],
            [
                "id": 2,
                "name": "Test 2",
                "email": "test2@example.com"
            ]
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试表结构升级
        static func testUpgradeTableStructure() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.upgradeTableStructure(
                sourceTable: "source_table",
                destTable: "dest_table",
                sourceSchema: Data.sourceTableSchema,
                destSchema: Data.destTableSchema,
                dbService: mockDBService
            )
            print("Table Structure Upgrade Result:", result)
        }
        
        /// 测试缺失数据清理
        static func testCleanupMissingData() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.cleanupMissingData(
                tableName: "test_table",
                primaryKey: "id",
                existingIds: [1, 2],
                dbService: mockDBService
            )
            print("Missing Data Cleanup Result:", result)
        }
        
        /// 测试调试模式下的数据验证
        static func testDebugDataValidation() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.validateTableData(
                tableName: "test_table",
                schema: Data.sourceTableSchema,
                debugMode: true,
                dbService: mockDBService
            )
            print("Debug Data Validation Result:", result)
        }
    }
} 