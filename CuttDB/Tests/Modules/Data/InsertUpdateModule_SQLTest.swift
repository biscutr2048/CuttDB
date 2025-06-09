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

class InsertUpdateModule_SQLTest: CuttDBTestCase {
    override func runTests() {
        print("Running InsertUpdateModule_SQLTest...")
        
        // 创建测试数据
        let testData: [String: Any] = [
            "tableName": "test_table",
            "columns": ["id", "name", "status", "created_at"],
            "values": [1, "Test", "active", "2024-03-20"],
            "updateData": [
                "name": "Updated Test",
                "status": "inactive"
            ],
            "batchData": [
                [1, "Test 1", "active", "2024-03-20"],
                [2, "Test 2", "active", "2024-03-20"],
                [3, "Test 3", "active", "2024-03-20"]
            ]
        ]
        
        // 创建Mock服务
        let mockService = MockCuttDBService()
        
        // 测试生成插入SQL
        print("Testing generateInsertSQL...")
        let insertSQL = CuttDB.generateInsertSQL(
            tableName: testData["tableName"] as! String,
            columns: testData["columns"] as! [String],
            values: testData["values"] as! [Any]
        )
        assert(!insertSQL.isEmpty, "Generate insert SQL failed")
        
        // 测试生成更新SQL
        print("Testing generateUpdateSQL...")
        let updateSQL = CuttDB.generateUpdateSQL(
            tableName: testData["tableName"] as! String,
            data: testData["updateData"] as! [String: Any],
            condition: "id = 1"
        )
        assert(!updateSQL.isEmpty, "Generate update SQL failed")
        
        // 测试生成Upsert SQL
        print("Testing generateUpsertSQL...")
        let upsertSQL = CuttDB.generateUpsertSQL(
            tableName: testData["tableName"] as! String,
            data: testData["updateData"] as! [String: Any],
            uniqueColumns: ["id"]
        )
        assert(!upsertSQL.isEmpty, "Generate upsert SQL failed")
        
        // 测试生成批量插入SQL
        print("Testing generateBatchInsertSQL...")
        let batchInsertSQL = CuttDB.generateBatchInsertSQL(
            tableName: testData["tableName"] as! String,
            columns: testData["columns"] as! [String],
            values: testData["batchData"] as! [[Any]]
        )
        assert(!batchInsertSQL.isEmpty, "Generate batch insert SQL failed")
        
        // 测试执行插入
        print("Testing executeInsert...")
        let insertResult = CuttDB.executeInsert(
            tableName: testData["tableName"] as! String,
            data: testData["updateData"] as! [String: Any],
            dbService: mockService
        )
        assert(insertResult, "Execute insert failed")
        
        // 测试执行更新
        print("Testing executeUpdate...")
        let updateResult = CuttDB.executeUpdate(
            sql: updateSQL,
            parameters: testData["updateData"] as! [String: Any]
        )
        assert(updateResult, "Execute update failed")
        
        // 测试执行Upsert
        print("Testing executeUpsert...")
        let upsertResult = CuttDB.executeUpsert(
            tableName: testData["tableName"] as! String,
            data: testData["updateData"] as! [String: Any],
            uniqueColumns: ["id"],
            dbService: mockService
        )
        assert(upsertResult, "Execute upsert failed")
        
        // 测试执行批量插入
        print("Testing executeBatchInsert...")
        let batchInsertResult = CuttDB.executeBatchInsert(
            tableName: testData["tableName"] as! String,
            columns: testData["columns"] as! [String],
            values: testData["batchData"] as! [[Any]],
            dbService: mockService
        )
        assert(batchInsertResult, "Execute batch insert failed")
        
        print("InsertUpdateModule_SQLTest completed successfully!")
    }
} 