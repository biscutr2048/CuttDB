import XCTest
@testable import CuttDB

/// Test class for index operations
final class MechanismModule_IndexTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "created_at INTEGER"
        ]
        
        static let indexColumns = ["name", "age"]
        static let uniqueIndexColumns = ["id"]
        
        static let testData: [[String: Any]] = [
            ["id": "1", "name": "Test1", "age": 20, "created_at": Date().timeIntervalSince1970],
            ["id": "2", "name": "Test2", "age": 30, "created_at": Date().timeIntervalSince1970],
            ["id": "3", "name": "Test3", "age": 40, "created_at": Date().timeIntervalSince1970]
        ]
    }
    
    override func setUp() {
        super.setUp()
        
        // Create test table
        try? db.createTable(
            name: TestData.table,
            columns: ["id", "name", "age", "created_at"]
        )
        
        // Insert test data
        for data in TestData.testData {
            try? db.insert(table: TestData.table, data: data)
        }
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test creating a normal index
    func testCreateIndex() throws {
        // Create index
        let indexName = "idx_\(TestData.table)_\(TestData.indexColumns.joined(separator: "_"))"
        let sql = "CREATE INDEX \(indexName) ON \(TestData.table) (\(TestData.indexColumns.joined(separator: ", ")))"
        try db.queryList(from: TestData.table, where: sql)
        
        // Verify index exists
        let indexes = try db.queryList(from: "sqlite_master", where: "type = 'index' AND tbl_name = '\(TestData.table)'")
        XCTAssertNotNil(indexes)
        XCTAssertTrue(indexes.contains { ($0["name"] as? String) == indexName })
    }
    
    /// Test creating a unique index
    func testCreateUniqueIndex() throws {
        // Create unique index
        let indexName = "idx_\(TestData.table)_\(TestData.uniqueIndexColumns.joined(separator: "_"))"
        let sql = "CREATE UNIQUE INDEX \(indexName) ON \(TestData.table) (\(TestData.uniqueIndexColumns.joined(separator: ", ")))"
        try db.queryList(from: TestData.table, where: sql)
        
        // Verify index exists
        let indexes = try db.queryList(from: "sqlite_master", where: "type = 'index' AND tbl_name = '\(TestData.table)'")
        XCTAssertNotNil(indexes)
        XCTAssertTrue(indexes.contains { ($0["name"] as? String) == indexName })
    }
    
    /// Test dropping an index
    func testDropIndex() throws {
        // Create index first
        let indexName = "idx_\(TestData.table)_\(TestData.indexColumns.joined(separator: "_"))"
        let createSQL = "CREATE INDEX \(indexName) ON \(TestData.table) (\(TestData.indexColumns.joined(separator: ", ")))"
        try db.queryList(from: TestData.table, where: createSQL)
        
        // Drop index
        let dropSQL = "DROP INDEX \(indexName)"
        try db.queryList(from: TestData.table, where: dropSQL)
        
        // Verify index is removed
        let indexes = try db.queryList(from: "sqlite_master", where: "type = 'index' AND tbl_name = '\(TestData.table)'")
        XCTAssertNotNil(indexes)
        XCTAssertFalse(indexes.contains { ($0["name"] as? String) == indexName })
    }
    
    /// Test query performance with index
    func testQueryPerformanceWithIndex() throws {
        // Create index
        let indexName = "idx_\(TestData.table)_\(TestData.indexColumns.joined(separator: "_"))"
        let sql = "CREATE INDEX \(indexName) ON \(TestData.table) (\(TestData.indexColumns.joined(separator: ", ")))"
        try db.queryList(from: TestData.table, where: sql)
        
        // Measure query performance
        measure {
            _ = try? db.queryList(
                from: TestData.table,
                where: "name = 'Test1' AND age > 10"
            )
        }
    }
    
    /// Test index on multiple columns
    func testMultiColumnIndex() throws {
        // Create multi-column index
        let indexName = "idx_\(TestData.table)_\(TestData.indexColumns.joined(separator: "_"))"
        let sql = "CREATE INDEX \(indexName) ON \(TestData.table) (\(TestData.indexColumns.joined(separator: ", ")))"
        try db.queryList(from: TestData.table, where: sql)
        
        // Verify index exists
        let indexes = try db.queryList(from: "sqlite_master", where: "type = 'index' AND tbl_name = '\(TestData.table)'")
        XCTAssertNotNil(indexes)
        XCTAssertTrue(indexes.contains { ($0["name"] as? String) == indexName })
        
        // Test query using indexed columns
        let result = try db.queryList(
            from: TestData.table,
            where: "name = 'Test1' AND age > 10"
        )
        XCTAssertNotNil(result)
    }
    
    /// Test index maintenance
    func testIndexMaintenance() throws {
        // Create index
        let indexName = "idx_\(TestData.table)_\(TestData.indexColumns.joined(separator: "_"))"
        let sql = "CREATE INDEX \(indexName) ON \(TestData.table) (\(TestData.indexColumns.joined(separator: ", ")))"
        try db.queryList(from: TestData.table, where: sql)
        
        // Insert new data
        let newData: [String: Any] = [
            "id": "4",
            "name": "Test4",
            "age": 50,
            "created_at": Date().timeIntervalSince1970
        ]
        try db.insert(table: TestData.table, data: newData)
        
        // Verify index is maintained
        let indexes = try db.queryList(from: "sqlite_master", where: "type = 'index' AND tbl_name = '\(TestData.table)'")
        XCTAssertNotNil(indexes)
        XCTAssertTrue(indexes.contains { ($0["name"] as? String) == indexName })
        
        // Test query with new data
        let result = try db.queryList(
            from: TestData.table,
            where: "name = 'Test4'"
        )
        XCTAssertEqual(result.count, 1)
    }
} 