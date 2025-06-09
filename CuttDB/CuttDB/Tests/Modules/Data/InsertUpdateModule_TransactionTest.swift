//
//  InsertUpdateModule_TransactionTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for transaction operations in the InsertUpdate module
class InsertUpdateModule_TransactionTest: XCTestCase {
    /// Database instance for testing
    var db: CuttDB!
    /// Mock service for testing
    var mockService: MockCuttDBService!
    
    /// Test data structure
    struct TestData {
        static let tableName = "transaction_test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "balance INTEGER"
        ]
        static let records = [
            ["id": 1, "name": "Account 1", "balance": 1000],
            ["id": 2, "name": "Account 2", "balance": 2000],
            ["id": 3, "name": "Account 3", "balance": 3000]
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
    
    /// Test basic transaction commit
    func testTransactionCommit() {
        // Arrange
        let transferAmount = 500
        
        // Act
        try? db.beginTransaction()
        try? db.update(
            table: TestData.tableName,
            data: ["balance": 500],
            where: ["id": 1]
        )
        try? db.update(
            table: TestData.tableName,
            data: ["balance": 2500],
            where: ["id": 2]
        )
        try? db.commitTransaction()
        
        // Assert
        let account1 = try? db.select(
            table: TestData.tableName,
            where: ["id": 1]
        )
        let account2 = try? db.select(
            table: TestData.tableName,
            where: ["id": 2]
        )
        
        XCTAssertNotNil(account1)
        XCTAssertNotNil(account2)
        XCTAssertEqual(account1?.first?["balance"] as? Int, 500)
        XCTAssertEqual(account2?.first?["balance"] as? Int, 2500)
    }
    
    /// Test transaction rollback
    func testTransactionRollback() {
        // Arrange
        let initialBalance1 = 1000
        let initialBalance2 = 2000
        
        // Act
        try? db.beginTransaction()
        try? db.update(
            table: TestData.tableName,
            data: ["balance": 500],
            where: ["id": 1]
        )
        try? db.update(
            table: TestData.tableName,
            data: ["balance": 2500],
            where: ["id": 2]
        )
        try? db.rollbackTransaction()
        
        // Assert
        let account1 = try? db.select(
            table: TestData.tableName,
            where: ["id": 1]
        )
        let account2 = try? db.select(
            table: TestData.tableName,
            where: ["id": 2]
        )
        
        XCTAssertNotNil(account1)
        XCTAssertNotNil(account2)
        XCTAssertEqual(account1?.first?["balance"] as? Int, initialBalance1)
        XCTAssertEqual(account2?.first?["balance"] as? Int, initialBalance2)
    }
    
    /// Test nested transactions
    func testNestedTransactions() {
        // Arrange
        let transferAmount = 500
        
        // Act
        try? db.beginTransaction()
        try? db.update(
            table: TestData.tableName,
            data: ["balance": 500],
            where: ["id": 1]
        )
        
        try? db.beginTransaction()
        try? db.update(
            table: TestData.tableName,
            data: ["balance": 2500],
            where: ["id": 2]
        )
        try? db.commitTransaction()
        
        try? db.commitTransaction()
        
        // Assert
        let account1 = try? db.select(
            table: TestData.tableName,
            where: ["id": 1]
        )
        let account2 = try? db.select(
            table: TestData.tableName,
            where: ["id": 2]
        )
        
        XCTAssertNotNil(account1)
        XCTAssertNotNil(account2)
        XCTAssertEqual(account1?.first?["balance"] as? Int, 500)
        XCTAssertEqual(account2?.first?["balance"] as? Int, 2500)
    }
    
    /// Test transaction with invalid operation
    func testTransactionWithInvalidOperation() {
        // Arrange
        let invalidData = ["balance": "invalid"]
        
        // Act & Assert
        try? db.beginTransaction()
        XCTAssertThrowsError(try db.update(
            table: TestData.tableName,
            data: invalidData,
            where: ["id": 1]
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
        try? db.rollbackTransaction()
        
        // Verify no changes were made
        let account1 = try? db.select(
            table: TestData.tableName,
            where: ["id": 1]
        )
        XCTAssertNotNil(account1)
        XCTAssertEqual(account1?.first?["balance"] as? Int, 1000)
    }
    
    /// Test performance
    func testPerformance() {
        // Act & Assert
        measure {
            try? db.beginTransaction()
            for i in 1...100 {
                try? db.update(
                    table: TestData.tableName,
                    data: ["balance": i * 100],
                    where: ["id": i % 3 + 1]
                )
            }
            try? db.commitTransaction()
        }
    }
} 