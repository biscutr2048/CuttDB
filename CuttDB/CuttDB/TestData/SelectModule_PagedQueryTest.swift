import Foundation

/// 选择模块 - 分页查询测试
struct SelectModule_PagedQueryTest {
    /// 测试数据
    struct Data {
        static let page1Data: [[String: Any]] = [
            [
                "id": 1,
                "name": "Item 1",
                "created_at": "2024-06-01"
            ],
            [
                "id": 2,
                "name": "Item 2",
                "created_at": "2024-06-02"
            ]
        ]
        
        static let page2Data: [[String: Any]] = [
            [
                "id": 3,
                "name": "Item 3",
                "created_at": "2024-06-03"
            ],
            [
                "id": 4,
                "name": "Item 4",
                "created_at": "2024-06-04"
            ]
        ]
        
        static let totalCount = 10
        static let pageSize = 2
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试基本分页查询
        static func testBasicPagedQuery() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generatePagedSelectSQL(
                tableName: "items",
                page: 1,
                pageSize: Data.pageSize,
                orderBy: "created_at",
                dbService: mockDBService
            )
            print("Basic Paged Query Result:", result)
            assert(result != nil, "Should generate basic paged query SQL")
        }
        
        /// 测试带条件的分页查询
        static func testPagedQueryWithConditions() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.generatePagedSelectSQL(
                tableName: "items",
                page: 1,
                pageSize: Data.pageSize,
                conditions: ["status": "active"],
                orderBy: "created_at",
                dbService: mockDBService
            )
            print("Paged Query With Conditions Result:", result)
            assert(result != nil, "Should generate paged query SQL with conditions")
        }
        
        /// 测试分页总数查询
        static func testPagedTotalCount() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.getTotalCount(
                tableName: "items",
                conditions: ["status": "active"],
                dbService: mockDBService
            )
            print("Paged Total Count Result:", result)
            assert(result > 0, "Should get total count for paged query")
        }
        
        /// 测试分页缓存
        static func testPagedQueryCache() {
            let mockDBService = MockCuttDBService()
            let result = CuttDB.cachePagedResults(
                tableName: "items",
                page: 1,
                pageSize: Data.pageSize,
                data: Data.page1Data,
                dbService: mockDBService
            )
            print("Paged Query Cache Result:", result)
            assert(result, "Should cache paged query results")
        }
    }
} 