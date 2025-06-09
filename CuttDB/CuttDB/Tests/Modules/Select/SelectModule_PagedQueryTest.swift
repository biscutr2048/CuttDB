//
//  SelectModule_PagedQueryTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for paged query operations
final class SelectModule_PagedQueryTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "created_at INTEGER"
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
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
        
        // Create test table
        _ = try? db.createTable(
            name: TestData.table,
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
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic paged query
    func testBasicPagedQuery() {
        // Arrange
        let table = TestData.table
        let pageSize = 10
        let pageNumber = 1
        
        // Act
        let result = try? db.selectPaged(
            table: table,
            pageSize: pageSize,
            pageNumber: pageNumber
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.records.count, pageSize)
        XCTAssertEqual(result?.totalCount, TestData.records.count)
        XCTAssertEqual(result?.totalPages, (TestData.records.count + pageSize - 1) / pageSize)
        XCTAssertEqual(result?.currentPage, pageNumber)
    }
    
    /// Test paged query with where clause
    func testPagedQueryWithWhere() {
        // Arrange
        let table = TestData.table
        let pageSize = 10
        let pageNumber = 1
        let whereClause = "age > ?"
        let params = [40]
        
        // Act
        let result = try? db.selectPaged(
            table: table,
            where: whereClause,
            params: params,
            pageSize: pageSize,
            pageNumber: pageNumber
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertLessThanOrEqual(result?.records.count ?? 0, pageSize)
        XCTAssertGreaterThan(result?.totalCount ?? 0, 0)
        XCTAssertEqual(result?.currentPage, pageNumber)
        
        // Verify all records match the condition
        for record in result?.records ?? [] {
            XCTAssertGreaterThan(record["age"] as? Int ?? 0, 40)
        }
    }
    
    /// Test paged query with order by
    func testPagedQueryWithOrderBy() {
        // Arrange
        let table = TestData.table
        let pageSize = 10
        let pageNumber = 1
        let orderBy = "age DESC"
        
        // Act
        let result = try? db.selectPaged(
            table: table,
            orderBy: orderBy,
            pageSize: pageSize,
            pageNumber: pageNumber
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.records.count, pageSize)
        
        // Verify records are ordered
        let records = result?.records ?? []
        for i in 0..<(records.count - 1) {
            let currentAge = records[i]["age"] as? Int ?? 0
            let nextAge = records[i + 1]["age"] as? Int ?? 0
            XCTAssertGreaterThanOrEqual(currentAge, nextAge)
        }
    }
    
    /// Test paged query with invalid page number
    func testPagedQueryWithInvalidPage() {
        // Arrange
        let table = TestData.table
        let pageSize = 10
        let invalidPage = 999
        
        // Act & Assert
        XCTAssertThrowsError(try db.selectPaged(
            table: table,
            pageSize: pageSize,
            pageNumber: invalidPage
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test paged query with zero page size
    func testPagedQueryWithZeroPageSize() {
        // Arrange
        let table = TestData.table
        let pageSize = 0
        let pageNumber = 1
        
        // Act & Assert
        XCTAssertThrowsError(try db.selectPaged(
            table: table,
            pageSize: pageSize,
            pageNumber: pageNumber
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let table = TestData.table
        let pageSize = 10
        let pageNumber = 1
        
        // Act & Assert
        measure {
            _ = try? db.selectPaged(
                table: table,
                pageSize: pageSize,
                pageNumber: pageNumber
            )
        }
    }
} 