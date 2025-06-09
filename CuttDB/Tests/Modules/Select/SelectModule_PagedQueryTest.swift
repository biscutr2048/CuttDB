import Foundation
import XCTest

class SelectModule_PagedQueryTest: XCTestCase {
    private var db: CuttDB!
    private var mockService: MockCuttDBService!
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
    }
    
    override func tearDown() {
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    func testBasicPagedQuery() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "status": "TEXT",
            "created_at": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "status": "active", "created_at": "2024-01-01"],
            ["id": "2", "name": "Jane", "status": "active", "created_at": "2024-01-02"],
            ["id": "3", "name": "Bob", "status": "inactive", "created_at": "2024-01-03"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试基本分页查询
        let results = db.queryWithPagination([String: Any].self, page: 1, pageSize: 2)
        XCTAssertEqual(results.count, 2, "Should return 2 records per page")
    }
    
    func testSortedPagedQuery() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "status": "TEXT",
            "created_at": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "status": "active", "created_at": "2024-01-01"],
            ["id": "2", "name": "Jane", "status": "active", "created_at": "2024-01-02"],
            ["id": "3", "name": "Bob", "status": "inactive", "created_at": "2024-01-03"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试带排序的分页查询
        let results = db.queryWithPagination([String: Any].self, page: 1, pageSize: 2, orderBy: "created_at DESC")
        XCTAssertEqual(results.count, 2, "Should return 2 records per page")
        XCTAssertEqual(results.first?["created_at"] as? String, "2024-01-03", "Should be sorted by created_at DESC")
    }
    
    func testFilteredPagedQuery() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "status": "TEXT",
            "created_at": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "status": "active", "created_at": "2024-01-01"],
            ["id": "2", "name": "Jane", "status": "active", "created_at": "2024-01-02"],
            ["id": "3", "name": "Bob", "status": "inactive", "created_at": "2024-01-03"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试带过滤的分页查询
        let results = db.queryWithPagination([String: Any].self, page: 1, pageSize: 2, whereClause: "status = 'active'")
        XCTAssertEqual(results.count, 2, "Should return 2 active records")
    }
    
    func testTotalCount() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "status": "TEXT",
            "created_at": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "status": "active", "created_at": "2024-01-01"],
            ["id": "2", "name": "Jane", "status": "active", "created_at": "2024-01-02"],
            ["id": "3", "name": "Bob", "status": "inactive", "created_at": "2024-01-03"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试总数查询
        let totalCount = db.getTotalCount([String: Any].self, whereClause: "status = 'active'")
        XCTAssertEqual(totalCount, 2, "Should have 2 active records")
    }
} 