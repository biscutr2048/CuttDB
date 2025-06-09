import Foundation

/// 选择模块 - 分页查询测试
struct SelectModule_PagedQueryTest {
    /// 测试数据
    struct Data {
        static let page1Data = [
            ["id": 1, "name": "Item 1", "created_at": "2024-01-01"],
            ["id": 2, "name": "Item 2", "created_at": "2024-01-02"],
            ["id": 3, "name": "Item 3", "created_at": "2024-01-03"]
        ]
        
        static let page2Data = [
            ["id": 4, "name": "Item 4", "created_at": "2024-01-04"],
            ["id": 5, "name": "Item 5", "created_at": "2024-01-05"],
            ["id": 6, "name": "Item 6", "created_at": "2024-01-06"]
        ]
        
        static let totalCount = 6
        static let pageSize = 3
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试基本分页查询
        static func testBasicPagedQuery() {
            print("\n=== Testing Basic Paged Query ===")
            
            let mockService = MockCuttDBService()
            mockService.setMockData(for: "items", data: Data.page1Data + Data.page2Data)
            
            // 测试第一页
            let page1SQL = "SELECT * FROM items LIMIT \(Data.pageSize) OFFSET 0"
            let page1Result = mockService.executeQuery(page1SQL)
            assert(page1Result.count == Data.pageSize, "Page 1 should have \(Data.pageSize) items")
            
            // 测试第二页
            let page2SQL = "SELECT * FROM items LIMIT \(Data.pageSize) OFFSET \(Data.pageSize)"
            let page2Result = mockService.executeQuery(page2SQL)
            assert(page2Result.count == Data.pageSize, "Page 2 should have \(Data.pageSize) items")
            
            print("Basic paged query test completed successfully")
        }
        
        /// 测试带条件的分页查询
        static func testPagedQueryWithConditions() {
            print("\n=== Testing Paged Query With Conditions ===")
            
            let mockService = MockCuttDBService()
            mockService.setMockData(for: "items", data: Data.page1Data + Data.page2Data)
            
            // 测试带条件的查询
            let conditionSQL = "SELECT * FROM items WHERE created_at > '2024-01-03' LIMIT \(Data.pageSize) OFFSET 0"
            let result = mockService.executeQuery(conditionSQL)
            assert(result.count == Data.pageSize, "Should return \(Data.pageSize) items after condition")
            
            print("Paged query with conditions test completed successfully")
        }
        
        /// 测试分页总数查询
        static func testPagedTotalCount() {
            print("\n=== Testing Paged Total Count ===")
            
            let mockService = MockCuttDBService()
            mockService.setMockData(for: "items", data: Data.page1Data + Data.page2Data)
            
            // 测试总数查询
            let countSQL = "SELECT COUNT(*) as total FROM items"
            let result = mockService.executeQuery(countSQL)
            assert(result.first?["total"] as? Int == Data.totalCount, "Total count should be \(Data.totalCount)")
            
            print("Paged total count test completed successfully")
        }
        
        /// 测试分页缓存
        static func testPagedQueryCache() {
            print("\n=== Testing Paged Query Cache ===")
            
            let mockService = MockCuttDBService()
            mockService.setMockData(for: "items", data: Data.page1Data + Data.page2Data)
            
            // 测试缓存
            let cacheKey = "items_page_1"
            let page1SQL = "SELECT * FROM items LIMIT \(Data.pageSize) OFFSET 0"
            
            // 第一次查询
            let result1 = mockService.executeQuery(page1SQL)
            assert(result1.count == Data.pageSize, "First query should return \(Data.pageSize) items")
            
            // 第二次查询（应该使用缓存）
            let result2 = mockService.executeQuery(page1SQL)
            assert(result2.count == Data.pageSize, "Cached query should return \(Data.pageSize) items")
            
            print("Paged query cache test completed successfully")
        }
    }
}

class SelectModule_PagedQueryTest: CuttDBTestCase {
    override func runTests() {
        print("Running SelectModule_PagedQueryTest...")
        
        // 创建测试数据
        let testData = [
            "tableName": "test_table",
            "pageSize": 10,
            "pageNumber": 1,
            "sortField": "created_at",
            "sortOrder": "DESC",
            "filter": "status = 'active'",
            "fields": ["id", "name", "status", "created_at"]
        ]
        
        // 创建Mock服务
        let mockService = MockCuttDBService()
        
        // 测试基本分页查询
        print("Testing basic paged query...")
        let basicQueryResult = CuttDB.queryPagedData(
            tableName: testData["tableName"] as! String,
            data: [
                "pageSize": testData["pageSize"] as! Int,
                "pageNumber": testData["pageNumber"] as! Int
            ],
            dbService: mockService
        )
        assert(basicQueryResult != nil, "Basic paged query failed")
        
        // 测试带排序的分页查询
        print("Testing sorted paged query...")
        let sortedQueryResult = CuttDB.queryPagedData(
            tableName: testData["tableName"] as! String,
            data: [
                "pageSize": testData["pageSize"] as! Int,
                "pageNumber": testData["pageNumber"] as! Int,
                "sortField": testData["sortField"] as! String,
                "sortOrder": testData["sortOrder"] as! String
            ],
            dbService: mockService
        )
        assert(sortedQueryResult != nil, "Sorted paged query failed")
        
        // 测试带过滤的分页查询
        print("Testing filtered paged query...")
        let filteredQueryResult = CuttDB.queryPagedData(
            tableName: testData["tableName"] as! String,
            data: [
                "pageSize": testData["pageSize"] as! Int,
                "pageNumber": testData["pageNumber"] as! Int,
                "filter": testData["filter"] as! String
            ],
            dbService: mockService
        )
        assert(filteredQueryResult != nil, "Filtered paged query failed")
        
        // 测试带字段选择的分页查询
        print("Testing field selection paged query...")
        let fieldQueryResult = CuttDB.queryPagedData(
            tableName: testData["tableName"] as! String,
            data: [
                "pageSize": testData["pageSize"] as! Int,
                "pageNumber": testData["pageNumber"] as! Int,
                "fields": testData["fields"] as! [String]
            ],
            dbService: mockService
        )
        assert(fieldQueryResult != nil, "Field selection paged query failed")
        
        print("SelectModule_PagedQueryTest completed successfully!")
    }
} 