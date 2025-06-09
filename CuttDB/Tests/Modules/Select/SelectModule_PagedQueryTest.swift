import Foundation

/// 选择模块 - 分页查询测试
class SelectModule_PagedQueryTest: CuttDBTestCase {
    private let cuttDB: CuttDB
    
    override init() {
        self.cuttDB = CuttDB(dbName: "test_paged_query.sqlite")
        super.init()
    }
    
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
        
        // 测试基本分页查询
        print("Testing basic paged query...")
        let basicQueryResult = cuttDB.queryPaged(
            from: testData["tableName"] as! String,
            page: testData["pageNumber"] as! Int,
            pageSize: testData["pageSize"] as! Int
        )
        assert(!basicQueryResult.isEmpty, "Basic paged query failed")
        
        // 测试带排序的分页查询
        print("Testing sorted paged query...")
        let sortedQueryResult = cuttDB.queryPaged(
            from: testData["tableName"] as! String,
            page: testData["pageNumber"] as! Int,
            pageSize: testData["pageSize"] as! Int,
            where: nil,
            orderBy: "\(testData["sortField"] as! String) \(testData["sortOrder"] as! String)"
        )
        assert(!sortedQueryResult.isEmpty, "Sorted paged query failed")
        
        // 测试带过滤的分页查询
        print("Testing filtered paged query...")
        let filteredQueryResult = cuttDB.queryPaged(
            from: testData["tableName"] as! String,
            page: testData["pageNumber"] as! Int,
            pageSize: testData["pageSize"] as! Int,
            where: testData["filter"] as! String
        )
        assert(!filteredQueryResult.isEmpty, "Filtered paged query failed")
        
        // 测试带字段选择的分页查询
        print("Testing field selection paged query...")
        let fieldQueryResult = cuttDB.queryPaged(
            from: testData["tableName"] as! String,
            page: testData["pageNumber"] as! Int,
            pageSize: testData["pageSize"] as! Int,
            where: nil,
            orderBy: nil,
            fields: testData["fields"] as! [String]
        )
        assert(!fieldQueryResult.isEmpty, "Field selection paged query failed")
        
        // 测试分页总数查询
        print("Testing total count query...")
        let totalCount = cuttDB.queryCount(
            from: testData["tableName"] as! String,
            where: testData["filter"] as! String
        )
        assert(totalCount >= 0, "Total count query failed")
        
        print("SelectModule_PagedQueryTest completed successfully!")
    }
} 