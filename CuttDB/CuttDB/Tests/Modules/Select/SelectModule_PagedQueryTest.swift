//
//  SelectModule_PagedQueryTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for paged query functionality in the Select module
class SelectModule_PagedQueryTest: XCTestCase {
    /// Database instance for testing
    var db: CuttDB!
    /// Mock service for testing
    var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "paged_test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "score REAL"
        ]
        static let records = [
            ["id": 1, "name": "Alice", "age": 20, "score": 85.5],
            ["id": 2, "name": "Bob", "age": 22, "score": 92.0],
            ["id": 3, "name": "Charlie", "age": 21, "score": 88.5],
            ["id": 4, "name": "David", "age": 23, "score": 90.0],
            ["id": 5, "name": "Eve", "age": 19, "score": 87.5],
            ["id": 6, "name": "Frank", "age": 24, "score": 91.0],
            ["id": 7, "name": "Grace", "age": 20, "score": 89.0],
            ["id": 8, "name": "Henry", "age": 22, "score": 86.5],
            ["id": 9, "name": "Ivy", "age": 21, "score": 93.0],
            ["id": 10, "name": "Jack", "age": 23, "score": 88.0]
        ]
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
        
        // Create test table
        try? db.createTable(
            name: TestData.tableName,
            columns: TestData.columns
        )
        
        // Insert test data
        for record in TestData.records {
            try? db.insert(
                table: TestData.tableName,
                data: record
            )
        }
    }
    
    override func tearDown() {
        // Clean up test table
        try? db.dropTable(name: TestData.tableName)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic paged query
    func testBasicPagedQuery() {
        // Arrange
        let pageSize = 3
        let pageNumber = 1
        
        // Act
        let result = try? db.selectPaged(
            table: TestData.tableName,
            pageSize: pageSize,
            pageNumber: pageNumber
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.records.count, pageSize)
        XCTAssertEqual(result?.totalCount, TestData.records.count)
        XCTAssertEqual(result?.totalPages, 4) // ceil(10/3)
    }
    
    /// Test sorted paged query
    func testSortedPagedQuery() {
        // Arrange
        let pageSize = 3
        let pageNumber = 1
        let sortBy = "score"
        let sortOrder = "DESC"
        
        // Act
        let result = try? db.selectPaged(
            table: TestData.tableName,
            pageSize: pageSize,
            pageNumber: pageNumber,
            sortBy: sortBy,
            sortOrder: sortOrder
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.records.count, pageSize)
        
        // Verify sorting
        let scores = result?.records.compactMap { $0["score"] as? Double } ?? []
        XCTAssertEqual(scores, scores.sorted(by: >))
    }
    
    /// Test filtered paged query
    func testFilteredPagedQuery() {
        // Arrange
        let pageSize = 3
        let pageNumber = 1
        let filter = ["age": 21]
        
        // Act
        let result = try? db.selectPaged(
            table: TestData.tableName,
            pageSize: pageSize,
            pageNumber: pageNumber,
            where: filter
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.records.count, 1) // Only one record with age 21
        XCTAssertEqual(result?.totalCount, 1)
        XCTAssertEqual(result?.totalPages, 1)
    }
    
    /// Test paged query with invalid page number
    func testInvalidPageNumber() {
        // Arrange
        let pageSize = 3
        let invalidPageNumber = 5 // Beyond total pages
        
        // Act
        let result = try? db.selectPaged(
            table: TestData.tableName,
            pageSize: pageSize,
            pageNumber: invalidPageNumber
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.records.count, 0)
        XCTAssertEqual(result?.totalCount, TestData.records.count)
        XCTAssertEqual(result?.totalPages, 4)
    }
    
    /// Test paged query with invalid page size
    func testInvalidPageSize() {
        // Arrange
        let invalidPageSize = 0
        let pageNumber = 1
        
        // Act & Assert
        XCTAssertThrowsError(try db.selectPaged(
            table: TestData.tableName,
            pageSize: invalidPageSize,
            pageNumber: pageNumber
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test total count query
    func testTotalCount() {
        // Act
        let result = try? db.selectCount(
            table: TestData.tableName
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertEqual(result, TestData.records.count)
    }
    
    /// Test performance
    func testPerformance() {
        // Act & Assert
        measure {
            _ = try? db.selectPaged(
                table: TestData.tableName,
                pageSize: 3,
                pageNumber: 1,
                sortBy: "score",
                sortOrder: "DESC"
            )
        }
    }
} 