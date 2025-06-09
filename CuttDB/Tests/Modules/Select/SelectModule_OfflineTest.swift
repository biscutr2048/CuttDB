import Foundation
import XCTest

class SelectModule_OfflineTest: XCTestCase {
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
    
    func testOfflineQuery() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "email": "TEXT",
            "last_updated": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "email": "john@example.com", "last_updated": "2024-01-01"],
            ["id": "2", "name": "Jane", "email": "jane@example.com", "last_updated": "2024-01-02"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试离线查询
        let results = db.queryObjects([String: Any].self, whereClause: nil)
        XCTAssertEqual(results.count, 2, "Should return all records")
        
        // 验证数据完整性
        let firstRecord = results.first
        XCTAssertEqual(firstRecord?["name"] as? String, "John", "Should have correct name")
        XCTAssertEqual(firstRecord?["email"] as? String, "john@example.com", "Should have correct email")
    }
    
    func testOfflineQueryWithFilter() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "email": "TEXT",
            "last_updated": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "email": "john@example.com", "last_updated": "2024-01-01"],
            ["id": "2", "name": "Jane", "email": "jane@example.com", "last_updated": "2024-01-02"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试带过滤的离线查询
        let results = db.queryObjects([String: Any].self, whereClause: "name = 'John'")
        XCTAssertEqual(results.count, 1, "Should return only John's record")
        
        // 验证数据完整性
        let firstRecord = results.first
        XCTAssertEqual(firstRecord?["name"] as? String, "John", "Should have correct name")
        XCTAssertEqual(firstRecord?["email"] as? String, "john@example.com", "Should have correct email")
    }
    
    func testOfflineQueryWithOrder() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "email": "TEXT",
            "last_updated": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "email": "john@example.com", "last_updated": "2024-01-01"],
            ["id": "2", "name": "Jane", "email": "jane@example.com", "last_updated": "2024-01-02"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试带排序的离线查询
        let results = db.queryObjects([String: Any].self, whereClause: nil, orderBy: "last_updated DESC")
        XCTAssertEqual(results.count, 2, "Should return all records")
        
        // 验证排序
        let firstRecord = results.first
        XCTAssertEqual(firstRecord?["name"] as? String, "Jane", "Should be sorted by last_updated DESC")
    }
} 