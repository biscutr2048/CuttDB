import Foundation

/// 选择模块 - 离线查询测试
struct SelectModule_OfflineTest {
    /// 测试数据
    struct Data {
        static let cachedResponse: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "email": "test@example.com",
            "last_updated": "2024-06-09T10:00:00Z"
        ]
        
        static let cachedListResponse: [[String: Any]] = [
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
        
        static let cachedSubTableResponse: [String: Any] = [
            "parent_id": 1,
            "items": [
                [
                    "id": 1,
                    "name": "Item 1"
                ],
                [
                    "id": 2,
                    "name": "Item 2"
                ]
            ]
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试基本离线响应恢复
        static func testBasicOfflineResponse() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.restoreLastResponse(
                api: "/user/1",
                method: "GET",
                dbService: mockDBService
            )
            print("Basic Offline Response Result:", result)
            assert(result != nil, "Should restore basic offline response")
        }
        
        /// 测试列表离线响应恢复
        static func testListOfflineResponse() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.restoreListResponse(
                api: "/users",
                method: "GET",
                page: 1,
                pageSize: 10,
                dbService: mockDBService
            )
            print("List Offline Response Result:", result)
            assert(result != nil, "Should restore list offline response")
        }
        
        /// 测试子表离线响应恢复
        static func testSubTableOfflineResponse() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.restoreSubTableResponse(
                parentTable: "users",
                parentId: 1,
                subTable: "posts",
                dbService: mockDBService
            )
            print("Sub Table Offline Response Result:", result)
            assert(result != nil, "Should restore sub table offline response")
        }
        
        /// 测试离线响应过期处理
        static func testOfflineResponseExpiration() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.handleExpiredResponse(
                api: "/user/1",
                method: "GET",
                maxAge: 3600,
                dbService: mockDBService
            )
            print("Offline Response Expiration Result:", result)
            assert(result != nil, "Should handle expired offline response")
        }
    }
} 