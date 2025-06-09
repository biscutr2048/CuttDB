//
//  CreateModule_TableDefinitionTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for table definition functionality
class CreateModule_TableDefinitionTest: XCTestCase {
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
            "age INTEGER",
            "email TEXT UNIQUE",
            "created_at INTEGER"
        ]
        static let invalidColumns = [
            "id INVALID_TYPE",
            "name",
            "age INTEGER INVALID_CONSTRAINT"
        ]
    }
    
    override func setUp() {
        super.setUp()
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        mockService = MockCuttDBService()
        db = CuttDB(configuration: config)
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.tableName)
        db = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test basic table creation
    func testBasicTableCreation() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        
        // Act
        let result = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let tableExists = try? db.tableExists(name: tableName)
        XCTAssertTrue(tableExists ?? false)
    }
    
    /// Test table creation with invalid columns
    func testInvalidColumnDefinition() {
        // Arrange
        let tableName = TestData.tableName
        let invalidColumns = TestData.invalidColumns
        
        // Act & Assert
        XCTAssertThrowsError(try db.createTable(
            name: tableName,
            columns: invalidColumns
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test duplicate table creation
    func testDuplicateTableCreation() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        
        // Create table first time
        _ = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Act & Assert
        XCTAssertThrowsError(try db.createTable(
            name: tableName,
            columns: columns
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test table creation with constraints
    func testTableWithConstraints() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        
        // Act
        let result = try? db.createTable(
            name: tableName,
            columns: columns
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify constraints
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "id" && $0.isPrimaryKey } ?? false)
        XCTAssertTrue(tableInfo?.columns.contains { $0.name == "email" && $0.isUnique } ?? false)
    }
    
    /// Test table creation with indexes
    func testTableWithIndexes() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        let indexes = [
            "idx_name": ["name"],
            "idx_email": ["email"]
        ]
        
        // Act
        let result = try? db.createTable(
            name: tableName,
            columns: columns,
            indexes: indexes
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify indexes
        let tableInfo = try? db.getTableInfo(name: tableName)
        XCTAssertNotNil(tableInfo)
        XCTAssertTrue(tableInfo?.indexes.contains { $0.name == "idx_name" } ?? false)
        XCTAssertTrue(tableInfo?.indexes.contains { $0.name == "idx_email" } ?? false)
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let tableName = TestData.tableName
        let columns = TestData.columns
        
        // Act & Assert
        measure {
            _ = try? db.createTable(
                name: tableName,
                columns: columns
            )
        }
    }
} 