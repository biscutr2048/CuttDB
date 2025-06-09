import Foundation
import XCTest

class DeleteModule_BatchTest: XCTestCase {
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
    
    func testBatchDelete() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "status": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "status": "active"],
            ["id": "2", "name": "Jane", "status": "active"],
            ["id": "3", "name": "Bob", "status": "inactive"],
            ["id": "4", "name": "Alice", "status": "inactive"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试批量删除
        let deletedCount = db.deleteObjects([String: Any].self, whereClause: "status = 'inactive'")
        XCTAssertEqual(deletedCount, 2, "Should delete 2 inactive records")
        
        // 验证结果
        let remainingCount = db.getTotalCount([String: Any].self, whereClause: nil)
        XCTAssertEqual(remainingCount, 2, "Should have 2 active records remaining")
    }
    
    func testBatchDeleteWithTransaction() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "status": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "status": "active"],
            ["id": "2", "name": "Jane", "status": "active"],
            ["id": "3", "name": "Bob", "status": "inactive"],
            ["id": "4", "name": "Alice", "status": "inactive"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试事务中的批量删除
        db.beginTransaction()
        let deletedCount = db.deleteObjects([String: Any].self, whereClause: "status = 'inactive'")
        XCTAssertEqual(deletedCount, 2, "Should delete 2 inactive records")
        db.commitTransaction()
        
        // 验证结果
        let remainingCount = db.getTotalCount([String: Any].self, whereClause: nil)
        XCTAssertEqual(remainingCount, 2, "Should have 2 active records remaining")
    }
    
    func testBatchDeleteWithRollback() {
        // 准备测试数据
        let tableName = "test_table"
        let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "status": "TEXT"
        ]
        
        // 创建表
        XCTAssertTrue(db.ensureTableExists(tableName: tableName, columns: columns))
        
        // 插入测试数据
        let testData = [
            ["id": "1", "name": "John", "status": "active"],
            ["id": "2", "name": "Jane", "status": "active"],
            ["id": "3", "name": "Bob", "status": "inactive"],
            ["id": "4", "name": "Alice", "status": "inactive"]
        ]
        
        for data in testData {
            XCTAssertTrue(db.insertObject(data))
        }
        
        // 测试事务回滚
        db.beginTransaction()
        let deletedCount = db.deleteObjects([String: Any].self, whereClause: "status = 'inactive'")
        XCTAssertEqual(deletedCount, 2, "Should delete 2 inactive records")
        db.rollbackTransaction()
        
        // 验证结果
        let remainingCount = db.getTotalCount([String: Any].self, whereClause: nil)
        XCTAssertEqual(remainingCount, 4, "Should have all records after rollback")
    }
} 