import Foundation

/// 插入/更新模块测试
struct InsertUpdateModuleTest {
    /// 测试数据
    struct Data {
        static let insertJSON: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "email": "test@example.com"
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试生成SQL语句
        static func testGenerateSQL() {
            let mockDBService = MockCuttDBService()
            
            // Test case 1: Insert new record
            let insertSQL = CuttDB.generateSQL(
                api: "/user",
                method: "POST",
                json: Data.insertJSON,
                dbService: mockDBService
            )
            print("Test 1 - Insert SQL:", insertSQL ?? "nil")
            
            // Test case 2: Update existing record
            mockDBService.shouldKeyExist = true
            let updateSQL = CuttDB.generateSQL(
                api: "/user",
                method: "PUT",
                json: Data.insertJSON,
                dbService: mockDBService
            )
            print("Test 2 - Update SQL:", updateSQL ?? "nil")
        }
    }
} 