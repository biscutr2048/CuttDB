import XCTest
@testable import CuttDB

/// Test class for offline query operations
final class SelectModule_OfflineTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id": "INTEGER PRIMARY KEY",
            "name": "TEXT",
            "age": "INTEGER",
            "created_at": "INTEGER"
        ]
        
        static let records: [[String: Any]] = (1...100).map { i in
            [
                "id": i,
                "name": "User \(i)",
                "age": 20 + (i % 50),
                "created_at": Date().timeIntervalSince1970 + Double(i)
            ]
        }
    }
    
    override func setUp() {
        super.setUp()
        
        // Create test table
        try? db.ensureTableExists(
            tableName: TestData.table,
            columns: TestData.columns
        )
        
        // Insert test data
        for record in TestData.records {
            _ = try? db.insertOrUpdate(
                table: TestData.table,
                record: record
            )
        }
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic offline query
    func testBasicOfflineQuery() {
        // Arrange
        let table = TestData.table
        
        // Act
        let results: [[String: Any]] = db.queryList(from: table)
        
        // Assert
        XCTAssertEqual(results.count, TestData.records.count)
        XCTAssertEqual(results.first?["name"] as? String, "User 1")
    }
    
    /// Test offline query with where clause
    func testOfflineQueryWithWhere() {
        // Arrange
        let table = TestData.table
        let whereClause = "age > 30"
        
        // Act
        let results: [[String: Any]] = db.queryList(from: table, where: whereClause)
        
        // Assert
        XCTAssertFalse(results.isEmpty)
        for result in results {
            XCTAssertGreaterThan(result["age"] as? Int ?? 0, 30)
        }
    }
    
    /// Test offline query with order by
    func testOfflineQueryWithOrderBy() {
        // Arrange
        let table = TestData.table
        let orderBy = "age DESC"
        
        // Act
        let results: [[String: Any]] = db.queryList(from: table, orderBy: orderBy)
        
        // Assert
        XCTAssertEqual(results.count, TestData.records.count)
        let ages = results.compactMap { $0["age"] as? Int }
        XCTAssertEqual(ages, ages.sorted(by: >))
    }
    
    /// Test offline query with limit
    func testOfflineQueryWithLimit() {
        // Arrange
        let table = TestData.table
        let limit = 10
        
        // Act
        let results: [[String: Any]] = db.queryList(from: table, limit: limit)
        
        // Assert
        XCTAssertEqual(results.count, limit)
    }
    
    /// Test offline query with complex conditions
    func testOfflineQueryWithComplexConditions() {
        // Arrange
        let table = TestData.table
        let whereClause = "age > 30 AND name LIKE 'User%'"
        let orderBy = "age DESC"
        let limit = 5
        
        // Act
        let results: [[String: Any]] = db.queryList(from: table, where: whereClause, orderBy: orderBy, limit: limit)
        
        // Assert
        XCTAssertLessThanOrEqual(results.count, limit)
        for result in results {
            XCTAssertGreaterThan(result["age"] as? Int ?? 0, 30)
            XCTAssertTrue((result["name"] as? String ?? "").hasPrefix("User"))
        }
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let table = TestData.table
        
        // Act & Assert
        measure {
            _ = db.queryList(from: table)
        }
    }
} 