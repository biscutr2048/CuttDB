import Foundation

/// 插入/更新模块 - SQL生成测试
struct InsertUpdateModule_SQLTest {
    /// 测试数据
    struct Data {
        static let insertData: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "email": "test@example.com",
            "age": 30,
            "status": "active",
            "created_at": "2024-03-20"
        ]
        
        static let updateData: [String: Any] = [
            "name": "Updated User",
            "email": "updated@example.com",
            "status": "inactive",
            "updated_at": "2024-03-21"
        ]
        
        static let upsertData: [String: Any] = [
            "id": 1,
            "name": "Upsert User",
            "email": "upsert@example.com",
            "status": "active",
            "updated_at": "2024-03-21"
        ]
        
        static let batchData: [[String: Any]] = [
            [
                "id": 1,
                "name": "User 1",
                "email": "user1@example.com"
            ],
            [
                "id": 2,
                "name": "User 2",
                "email": "user2@example.com"
            ]
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试插入SQL生成
        static func testInsertSQLGeneration() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generateInsertSQL(
                tableName: "users",
                data: Data.insertData,
                dbService: mockDBService
            )
            print("Insert SQL:", result)
            assert(result != nil, "Should generate insert SQL successfully")
        }
        
        /// 测试更新SQL生成
        static func testUpdateSQLGeneration() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generateUpdateSQL(
                tableName: "users",
                data: Data.updateData,
                conditions: ["id": 1],
                dbService: mockDBService
            )
            print("Update SQL:", result)
            assert(result != nil, "Should generate update SQL successfully")
        }
        
        /// 测试Upsert SQL生成
        static func testUpsertSQLGeneration() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generateUpsertSQL(
                tableName: "users",
                data: Data.upsertData,
                uniqueColumns: ["id"],
                dbService: mockDBService
            )
            print("Upsert SQL:", result)
            assert(result != nil, "Should generate upsert SQL successfully")
        }
        
        /// 测试批量插入SQL生成
        static func testBatchInsertSQLGeneration() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generateBatchInsertSQL(
                tableName: "users",
                dataList: Data.batchData,
                dbService: mockDBService
            )
            print("Batch Insert SQL:", result)
            assert(result != nil, "Should generate batch insert SQL successfully")
        }
        
        /// 测试SQL参数绑定
        static func testSQLParameterBinding() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.bindSQLParameters(
                sql: "INSERT INTO users (name, email) VALUES (?, ?)",
                parameters: ["Test User", "test@example.com"],
                dbService: mockDBService
            )
            print("SQL Parameter Binding Result:", result)
            assert(result != nil, "Should bind SQL parameters successfully")
        }
        
        /// 测试SQL验证
        static func testSQLValidation() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.validateSQL(
                sql: "INSERT INTO users (name, email) VALUES (?, ?)",
                parameters: ["Test User", "test@example.com"],
                dbService: mockDBService
            )
            print("SQL Validation Result:", result)
            assert(result, "Should validate SQL successfully")
        }
    }
} 