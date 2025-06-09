import Foundation

/// 选择模块测试
struct SelectModuleTest {
    /// 测试数据
    struct Data {
        static let userData: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "email": "test@example.com",
            "created_at": "2024-06-09"
        ]
        
        static let userListData: [[String: Any]] = [
            [
                "id": 1,
                "name": "User 1",
                "email": "user1@example.com"
            ],
            [
                "id": 2,
                "name": "User 2",
                "email": "user2@example.com"
            ],
            [
                "id": 3,
                "name": "User 3",
                "email": "user3@example.com"
            ]
        ]
        
        static let businessKeyData: [String: Any] = [
            "order_id": "ORD-001",
            "customer_id": "CUST-001",
            "status": "pending",
            "items": [
                ["product_id": "PROD-001", "quantity": 2],
                ["product_id": "PROD-002", "quantity": 1]
            ]
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试离线加载响应
        static func testLoadResponseOffline() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.restoreLastResponse(
                api: "/user/1",
                method: "GET",
                dbService: mockDBService
            )
            print("Offline Response Result:", result)
        }
        
        /// 测试对象查询SQL生成
        static func testSelectObjectSQL() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generateSelectSQL(
                tableName: "users",
                conditions: ["id": 1],
                dbService: mockDBService
            )
            print("Select Object SQL:", result)
        }
        
        /// 测试分页列表查询SQL生成
        static func testSelectListPagedSQL() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generatePagedSelectSQL(
                tableName: "users",
                page: 1,
                pageSize: 10,
                orderBy: "created_at",
                dbService: mockDBService
            )
            print("Select List Paged SQL:", result)
        }
        
        /// 测试业务键查询
        static func testSelectByBusinessKey() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generateBusinessKeySelectSQL(
                tableName: "orders",
                businessKeys: ["order_id", "customer_id"],
                values: ["ORD-001", "CUST-001"],
                dbService: mockDBService
            )
            print("Business Key Select SQL:", result)
        }
    }
} 