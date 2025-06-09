import Foundation

/// 插入/更新模块 - SQL生成测试
struct InsertUpdateModule_SQLTest {
    /// 测试数据
    struct Data {
        static let insertData = [
            "id": 1,
            "name": "Test User",
            "email": "test@example.com",
            "created_at": "2024-01-01"
        ]
        
        static let updateData = [
            "name": "Updated User",
            "email": "updated@example.com"
        ]
        
        static let upsertData = [
            "id": 1,
            "name": "Upsert User",
            "email": "upsert@example.com",
            "created_at": "2024-01-01"
        ]
        
        static let batchData = [
            [
                "id": 1,
                "name": "User 1",
                "email": "user1@example.com",
                "created_at": "2024-01-01"
            ],
            [
                "id": 2,
                "name": "User 2",
                "email": "user2@example.com",
                "created_at": "2024-01-02"
            ]
        ]
    }
    
    /// 测试逻辑
    struct ServiceLogic {
        /// 测试服务层SQL生成
        static func testServiceSQLGeneration() {
            print("\n=== Testing Service Layer SQL Generation ===")
            
            let mockService = MockCuttDBService()
            
            // 测试插入SQL生成
            let insertSQL = mockService.generateInsertSQL(
                tableName: "users",
                data: Data.insertData
            )
            assert(insertSQL != nil, "Should generate insert SQL")
            
            // 测试更新SQL生成
            let updateSQL = mockService.generateUpdateSQL(
                tableName: "users",
                data: Data.updateData,
                conditions: ["id": 1]
            )
            assert(updateSQL != nil, "Should generate update SQL")
            
            // 测试upsert SQL生成
            let upsertSQL = mockService.generateUpsertSQL(
                tableName: "users",
                data: Data.upsertData,
                uniqueColumns: ["id"]
            )
            assert(upsertSQL != nil, "Should generate upsert SQL")
            
            // 测试批量插入SQL生成
            let batchInsertSQL = mockService.generateBatchInsertSQL(
                tableName: "users",
                dataList: Data.batchData
            )
            assert(batchInsertSQL != nil, "Should generate batch insert SQL")
            
            print("Service layer SQL generation test completed successfully")
        }
        
        /// 测试服务层SQL执行
        static func testServiceSQLExecution() {
            print("\n=== Testing Service Layer SQL Execution ===")
            
            let mockService = MockCuttDBService()
            
            // 测试插入执行
            let insertResult = mockService.executeInsert(
                tableName: "users",
                data: Data.insertData
            )
            assert(insertResult, "Should execute insert successfully")
            
            // 测试更新执行
            let updateResult = mockService.executeUpdate(
                tableName: "users",
                data: Data.updateData,
                conditions: ["id": 1]
            )
            assert(updateResult, "Should execute update successfully")
            
            // 测试upsert执行
            let upsertResult = mockService.executeUpsert(
                tableName: "users",
                data: Data.upsertData,
                uniqueColumns: ["id"]
            )
            assert(upsertResult, "Should execute upsert successfully")
            
            // 测试批量插入执行
            let batchInsertResult = mockService.executeBatchInsert(
                tableName: "users",
                dataList: Data.batchData
            )
            assert(batchInsertResult, "Should execute batch insert successfully")
            
            print("Service layer SQL execution test completed successfully")
        }
    }
    
    struct InterfaceLogic {
        /// 测试接口层插入操作
        static func testInterfaceInsert() {
            print("\n=== Testing Interface Layer Insert ===")
            
            let mockService = MockCuttDBService()
            let cuttDB = CuttDB(dbService: mockService)
            
            // 测试插入操作
            let result = cuttDB.insert(
                tableName: "users",
                data: Data.insertData
            )
            assert(result, "Should insert data through interface")
            
            // 验证插入结果
            let insertedData = cuttDB.select(
                tableName: "users",
                conditions: ["id": 1]
            )
            assert(insertedData.count == 1, "Should find inserted record")
            
            print("Interface layer insert test completed successfully")
        }
        
        /// 测试接口层更新操作
        static func testInterfaceUpdate() {
            print("\n=== Testing Interface Layer Update ===")
            
            let mockService = MockCuttDBService()
            let cuttDB = CuttDB(dbService: mockService)
            
            // 先插入数据
            _ = cuttDB.insert(tableName: "users", data: Data.insertData)
            
            // 测试更新操作
            let result = cuttDB.update(
                tableName: "users",
                data: Data.updateData,
                conditions: ["id": 1]
            )
            assert(result, "Should update data through interface")
            
            // 验证更新结果
            let updatedData = cuttDB.select(
                tableName: "users",
                conditions: ["id": 1]
            )
            assert(updatedData.first?["name"] as? String == Data.updateData["name"], "Should find updated record")
            
            print("Interface layer update test completed successfully")
        }
        
        /// 测试接口层upsert操作
        static func testInterfaceUpsert() {
            print("\n=== Testing Interface Layer Upsert ===")
            
            let mockService = MockCuttDBService()
            let cuttDB = CuttDB(dbService: mockService)
            
            // 测试upsert操作
            let result = cuttDB.upsert(
                tableName: "users",
                data: Data.upsertData,
                uniqueColumns: ["id"]
            )
            assert(result, "Should upsert data through interface")
            
            // 验证upsert结果
            let upsertedData = cuttDB.select(
                tableName: "users",
                conditions: ["id": 1]
            )
            assert(upsertedData.count == 1, "Should find upserted record")
            
            print("Interface layer upsert test completed successfully")
        }
        
        /// 测试接口层批量插入操作
        static func testInterfaceBatchInsert() {
            print("\n=== Testing Interface Layer Batch Insert ===")
            
            let mockService = MockCuttDBService()
            let cuttDB = CuttDB(dbService: mockService)
            
            // 测试批量插入操作
            let result = cuttDB.batchInsert(
                tableName: "users",
                dataList: Data.batchData
            )
            assert(result, "Should batch insert data through interface")
            
            // 验证批量插入结果
            let insertedData = cuttDB.select(tableName: "users")
            assert(insertedData.count == Data.batchData.count, "Should find all inserted records")
            
            print("Interface layer batch insert test completed successfully")
        }
    }
} 