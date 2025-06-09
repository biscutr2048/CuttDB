//
//  ListPropertiesModule_ComplexTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Test class for complex list properties operations
final class ListPropertiesModule_ComplexTest: CuttDBTestCase {
    /// Test data structure
    struct TestData {
        static let table = "test_table"
        static let columns = [
            "id INTEGER PRIMARY KEY",
            "name TEXT",
            "age INTEGER",
            "scores TEXT",
            "tags TEXT",
            "metadata TEXT"
        ]
        
        static let simpleRecord: [String: Any] = [
            "id": 1,
            "name": "Test User",
            "age": 25,
            "scores": "[85, 90, 95]",
            "tags": "[\"tag1\", \"tag2\"]",
            "metadata": "{\"key1\": \"value1\", \"key2\": 123}"
        ]
        
        static let complexRecord: [String: Any] = [
            "id": 2,
            "name": "Complex User",
            "age": 30,
            "scores": "[100, 95, 90, 85]",
            "tags": "[\"tag1\", \"tag2\", \"tag3\", \"tag4\"]",
            "metadata": """
            {
                "key1": "value1",
                "key2": 123,
                "key3": [1, 2, 3],
                "key4": {"nested": "value"}
            }
            """
        ]
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try? db.dropTable(name: TestData.table)
        super.tearDown()
    }
    
    // MARK: - Test Methods
    
    /// Test simple list properties
    func testSimpleListProperties() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let record = TestData.simpleRecord
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Insert test data
        let result = try? db.insert(
            table: table,
            data: record
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let records = try? db.select(
            table: table,
            where: "id = ?",
            params: [1]
        )
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records?.count, 1)
        
        if let firstRecord = records?.first {
            XCTAssertEqual(firstRecord["id"] as? Int, 1)
            XCTAssertEqual(firstRecord["name"] as? String, "Test User")
            XCTAssertEqual(firstRecord["age"] as? Int, 25)
            
            let scores = firstRecord["scores"] as? String
            XCTAssertNotNil(scores)
            XCTAssertEqual(scores, "[85, 90, 95]")
            
            let tags = firstRecord["tags"] as? String
            XCTAssertNotNil(tags)
            XCTAssertEqual(tags, "[\"tag1\", \"tag2\"]")
            
            let metadata = firstRecord["metadata"] as? String
            XCTAssertNotNil(metadata)
            XCTAssertEqual(metadata, "{\"key1\": \"value1\", \"key2\": 123}")
        }
    }
    
    /// Test complex list properties
    func testComplexListProperties() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let record = TestData.complexRecord
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Insert test data
        let result = try? db.insert(
            table: table,
            data: record
        )
        
        // Assert
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.success ?? false)
        
        // Verify
        let records = try? db.select(
            table: table,
            where: "id = ?",
            params: [2]
        )
        
        XCTAssertNotNil(records)
        XCTAssertEqual(records?.count, 1)
        
        if let firstRecord = records?.first {
            XCTAssertEqual(firstRecord["id"] as? Int, 2)
            XCTAssertEqual(firstRecord["name"] as? String, "Complex User")
            XCTAssertEqual(firstRecord["age"] as? Int, 30)
            
            let scores = firstRecord["scores"] as? String
            XCTAssertNotNil(scores)
            XCTAssertEqual(scores, "[100, 95, 90, 85]")
            
            let tags = firstRecord["tags"] as? String
            XCTAssertNotNil(tags)
            XCTAssertEqual(tags, "[\"tag1\", \"tag2\", \"tag3\", \"tag4\"]")
            
            let metadata = firstRecord["metadata"] as? String
            XCTAssertNotNil(metadata)
            XCTAssertEqual(metadata, """
            {
                "key1": "value1",
                "key2": 123,
                "key3": [1, 2, 3],
                "key4": {"nested": "value"}
            }
            """)
        }
    }
    
    /// Test invalid list properties
    func testInvalidListProperties() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let invalidRecord: [String: Any] = [
            "id": 3,
            "name": "Invalid User",
            "age": "not a number",
            "scores": "invalid json",
            "tags": 123,
            "metadata": ["invalid": "type"]
        ]
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Act & Assert
        XCTAssertThrowsError(try db.insert(
            table: table,
            data: invalidRecord
        )) { error in
            XCTAssertTrue(error is CuttDBError)
        }
    }
    
    /// Test performance
    func testPerformance() {
        // Arrange
        let table = TestData.table
        let columns = TestData.columns
        let record = TestData.complexRecord
        
        // Create test table
        _ = try? db.createTable(
            name: table,
            columns: columns
        )
        
        // Act & Assert
        measure {
            _ = try? db.insert(
                table: table,
                data: record
            )
        }
    }
} 