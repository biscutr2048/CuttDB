import Foundation

/// 创建模块测试
struct CreateModuleTest {
    /// 测试数据
    struct Data {
        static let complexJSON: [String: Any] = [
            "id": 123,
            "name": "Alice",
            "profile": [
                "age": 30,
                "city": "Beijing",
                "contact": [
                    "email": "alice@example.com",
                    "phone": "123456"
                ]
            ],
            "tags": ["swift", "macos"],
            "meta": NSNull(),
            "history": [
                [
                    "date": "2024-06-01",
                    "action": "login"
                ],
                [
                    "date": "2024-06-02",
                    "action": "logout"
                ]
            ]
        ]
        
        static let tableWithIndex: [String: Any] = [
            "id": 1,
            "name": "Test",
            "email": "test@example.com",
            "created_at": "2024-06-09",
            "status": "active"
        ]
        
        static let nestedListData: [String: Any] = [
            "id": 1,
            "name": "Order",
            "items": [
                [
                    "id": 101,
                    "product": "Item 1",
                    "quantity": 2
                ],
                [
                    "id": 102,
                    "product": "Item 2",
                    "quantity": 1
                ]
            ],
            "customer": [
                "id": 201,
                "name": "Customer 1",
                "address": "Address 1"
            ]
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试从JSON结构提取表格定义
        static func testExtractTableDefinition() {
            let def = CuttDB.extractTableDefinition(from: Data.complexJSON)
            print("Table Definition:", def)
            // Expected output: [("id", "TEXT"), ("name", "TEXT"), ("profile", "TEXT"), ("tags", "TEXT"), ("meta", "TEXT"), ("history", "TEXT")]
        }
        
        /// 测试自动创建表（如果不存在）
        static func testAutoCreateTable() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.ensureTableExists(
                tableName: "test_table",
                columns: [("id", "INTEGER"), ("name", "TEXT")],
                dbService: mockDBService
            )
            print("Auto Create Table Result:", result)
        }
        
        /// 测试自动创建索引
        static func testAutoCreateIndex() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.createIndexIfNeeded(
                tableName: "test_table",
                columns: ["email", "status"],
                dbService: mockDBService
            )
            print("Auto Create Index Result:", result)
        }
        
        /// 测试处理嵌套列表属性
        static func testHandleNestedListProperties() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.handleListProperties(
                api: "/order",
                method: "POST",
                json: Data.nestedListData,
                dbService: mockDBService
            )
            print("Nested List Properties Result:", result)
        }
    }
} 