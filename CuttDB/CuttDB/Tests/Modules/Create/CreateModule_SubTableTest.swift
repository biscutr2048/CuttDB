import Foundation

/// 创建模块 - 子表处理测试
struct CreateModule_SubTableTest {
    /// 测试数据
    struct Data {
        static let orderWithItems: [String: Any] = [
            "id": 1,
            "order_number": "ORD-001",
            "customer": [
                "id": 101,
                "name": "Customer 1",
                "email": "customer1@example.com"
            ],
            "items": [
                [
                    "id": 1,
                    "product_id": "PROD-001",
                    "quantity": 2,
                    "price": 99.99
                ],
                [
                    "id": 2,
                    "product_id": "PROD-002",
                    "quantity": 1,
                    "price": 149.99
                ]
            ],
            "shipping": [
                "address": "123 Main St",
                "city": "Beijing",
                "country": "China"
            ]
        ]
        
        static let userWithPosts: [String: Any] = [
            "id": 1,
            "username": "user1",
            "profile": [
                "name": "User One",
                "bio": "Test user"
            ],
            "posts": [
                [
                    "id": 1,
                    "title": "Post 1",
                    "content": "Content 1",
                    "tags": ["swift", "ios"]
                ],
                [
                    "id": 2,
                    "title": "Post 2",
                    "content": "Content 2",
                    "tags": ["database", "sql"]
                ]
            ]
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试订单子表创建
        static func testOrderSubTableCreation() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.handleListProperties(
                api: "/order",
                method: "POST",
                json: Data.orderWithItems,
                dbService: mockDBService
            )
            print("Order Sub Table Creation Result:", result)
            assert(result, "Should create order sub tables successfully")
        }
        
        /// 测试用户帖子子表创建
        static func testUserPostsSubTableCreation() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.handleListProperties(
                api: "/user",
                method: "POST",
                json: Data.userWithPosts,
                dbService: mockDBService
            )
            print("User Posts Sub Table Creation Result:", result)
            assert(result, "Should create user posts sub tables successfully")
        }
        
        /// 测试嵌套子表关系
        static func testNestedSubTableRelations() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.handleNestedSubTables(
                parentTable: "orders",
                parentId: 1,
                json: Data.orderWithItems,
                dbService: mockDBService
            )
            print("Nested Sub Table Relations Result:", result)
            assert(result, "Should handle nested sub table relations successfully")
        }
        
        /// 测试子表外键约束
        static func testSubTableForeignKeyConstraints() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.createSubTableWithConstraints(
                parentTable: "orders",
                subTable: "order_items",
                columns: [
                    ("id", "INTEGER"),
                    ("order_id", "INTEGER"),
                    ("product_id", "TEXT"),
                    ("quantity", "INTEGER"),
                    ("price", "REAL")
                ],
                foreignKey: ("order_id", "orders", "id"),
                dbService: mockDBService
            )
            print("Sub Table Foreign Key Constraints Result:", result)
            assert(result, "Should create sub table with foreign key constraints successfully")
        }
    }
} 