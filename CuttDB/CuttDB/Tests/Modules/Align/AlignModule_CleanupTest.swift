//
//  AlignModule_CleanupTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for cleanup functionality in the Align module
class AlignModule_CleanupTest: XCTestCase {
    /// Database instance for testing
    private var db: CuttDB!
    /// Mock service for testing
    private var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "email TEXT"
        ]
        static let duplicateRecords = [
            ["id": 1, "name": "John", "email": "john@example.com"],
            ["id": 2, "name": "John", "email": "john@example.com"],
            ["id": 3, "name": "Jane", "email": "jane@example.com"]
        ]
        
        static let sourceTable = "source_table"
        static let targetTable = "target_table"
        static let sourceRecords = [
            ["id": 1, "name": "John"],
            ["id": 2, "name": "Jane"]
        ]
        static let targetRecords = [
            ["id": 1, "name": "John"],
            ["id": 3, "name": "Bob"]
        ]
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
    }
    
    override func tearDown() {
        // Clean up test tables
        try? db.dropTable(name: TestData.tableName)
        try? db.dropTable(name: TestData.sourceTable)
        try? db.dropTable(name: TestData.targetTable)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test cleanup of duplicate records
    func testCleanupDuplicates() {
        // Arrange
        try? db.createTable(
            name: TestData.tableName,
            columns: TestData.columns
        )
        
        for record in TestData.duplicateRecords {
            try? db.insert(
                table: TestData.tableName,
                data: record
            )
        }
        
        // Act
        let aligner = TableAligner(service: mockService)
        let result = aligner.cleanupDuplicates(
            TestData.tableName,
            uniqueColumns: ["name", "email"]
        )
        
        // Assert
        XCTAssertTrue(result)
        
        // Verify
        let remainingRecords = try? db.select(
            table: TestData.tableName,
            where: ["name": "John"]
        )
        XCTAssertNotNil(remainingRecords)
        XCTAssertEqual(remainingRecords?.count, 1)
    }
    
    /// Test cleanup of missing data
    func testDropMissingData() {
        // Arrange
        try? db.createTable(
            name: TestData.sourceTable,
            columns: ["id INTEGER PRIMARY KEY", "name TEXT"]
        )
        try? db.createTable(
            name: TestData.targetTable,
            columns: ["id INTEGER PRIMARY KEY", "name TEXT"]
        )
        
        for record in TestData.sourceRecords {
            try? db.insert(
                table: TestData.sourceTable,
                data: record
            )
        }
        
        for record in TestData.targetRecords {
            try? db.insert(
                table: TestData.targetTable,
                data: record
            )
        }
        
        // Act
        let aligner = TableAligner(service: mockService)
        let result = aligner.dropMissingData(
            sourceTable: TestData.sourceTable,
            targetTable: TestData.targetTable
        )
        
        // Assert
        XCTAssertTrue(result)
        
        // Verify
        let remainingRecords = try? db.select(
            table: TestData.targetTable,
            where: ["name": "Bob"]
        )
        XCTAssertNotNil(remainingRecords)
        XCTAssertEqual(remainingRecords?.count, 0)
    }
    
    /// Test table alignment
    func testAlignTable() {
        // Arrange
        try? db.createTable(
            name: TestData.sourceTable,
            columns: TestData.columns
        )
        
        for record in TestData.sourceRecords {
            try? db.insert(
                table: TestData.sourceTable,
                data: record
            )
        }
        
        // Act
        let aligner = TableAligner(service: mockService)
        let result = aligner.alignTable(
            sourceTable: TestData.sourceTable,
            targetTable: TestData.targetTable,
            columns: TestData.columns
        )
        
        // Assert
        XCTAssertTrue(result)
        
        // Verify
        let targetRecords = try? db.select(table: TestData.targetTable)
        XCTAssertNotNil(targetRecords)
        XCTAssertEqual(targetRecords?.count, 2)
    }
    
    /// Test cleanup with invalid table
    func testCleanupInvalidTable() {
        // Arrange
        let aligner = TableAligner(service: mockService)
        
        // Act & Assert
        XCTAssertFalse(aligner.cleanupDuplicates(
            "invalid_table",
            uniqueColumns: ["name", "email"]
        ))
    }
    
    /// Test cleanup with invalid columns
    func testCleanupInvalidColumns() {
        // Arrange
        try? db.createTable(
            name: TestData.tableName,
            columns: TestData.columns
        )
        
        let aligner = TableAligner(service: mockService)
        
        // Act & Assert
        XCTAssertFalse(aligner.cleanupDuplicates(
            TestData.tableName,
            uniqueColumns: ["invalid_column"]
        ))
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        try? db.createTable(
            name: TestData.tableName,
            columns: TestData.columns
        )
        
        // Insert large number of records
        for i in 1...1000 {
            try? db.insert(
                table: TestData.tableName,
                data: [
                    "id": i,
                    "name": "User \(i)",
                    "email": "user\(i)@example.com"
                ]
            )
        }
        
        let aligner = TableAligner(service: mockService)
        
        // Act & Assert
        measure {
            _ = aligner.cleanupDuplicates(
                TestData.tableName,
                uniqueColumns: ["name", "email"]
            )
        }
    }
} 