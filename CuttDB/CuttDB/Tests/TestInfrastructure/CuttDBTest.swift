//
//  CuttDBTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest
@testable import CuttDB

/// Base test class for all CuttDB tests
class CuttDBTestCase: XCTestCase {
    var db: CuttDB!
    
    override func setUp() {
        super.setUp()
        db = CuttDB()
    }
    
    override func tearDown() {
        db = nil
        super.tearDown()
    }
}

/// Test module enumeration
enum TestModule: String, CaseIterable {
    case create = "Create"
    case select = "Select"
    case insertUpdate = "InsertUpdate"
    case delete = "Delete"
    case align = "Align"
    case mechanism = "Mechanism"
    
    var testClasses: [XCTestCase.Type] {
        switch self {
        case .create:
            return [
                CreateModule_TableDefinitionTest.self,
                CreateModule_SubTableTest.self,
                CreateModule_AutoCreateTest.self
            ]
        case .select:
            return [
                SelectModule_OfflineTest.self,
                SelectModule_PagedQueryTest.self
            ]
        case .insertUpdate:
            return [
                InsertUpdateModule_SQLTest.self,
                InsertUpdateModule_TransactionTest.self
            ]
        case .delete:
            return [
                DeleteModule_BatchTest.self
            ]
        case .align:
            return [
                AlignModule_UpgradeTest.self
            ]
        case .mechanism:
            return [
                MechanismModule_IndexTest.self
            ]
        }
    }
}

/// Test class for Create module
final class CreateModule_TableDefinitionTest: CuttDBTestCase {
    func testTableDefinition() throws {
        // Test table definition
        let tableName = "test_table"
        let columns = ["id", "name", "age"]
        
        try db.createTable(name: tableName, columns: columns)
        
        // Verify table exists
        let tables = try db.listTables()
        XCTAssertTrue(tables.contains(tableName))
    }
}

final class CreateModule_SubTableTest: CuttDBTestCase {
    func testSubTable() throws {
        // Test sub-table creation
        let parentTable = "parent_table"
        let childTable = "child_table"
        
        try db.createTable(name: parentTable, columns: ["id", "name"])
        try db.createTable(name: childTable, columns: ["id", "parent_id", "value"])
        
        // Verify tables exist
        let tables = try db.listTables()
        XCTAssertTrue(tables.contains(parentTable))
        XCTAssertTrue(tables.contains(childTable))
    }
}

final class CreateModule_AutoCreateTest: CuttDBTestCase {
    func testAutoCreate() throws {
        // Test auto-create functionality
        let tableName = "auto_table"
        let data = ["id": "1", "name": "Test"]
        
        try db.insert(table: tableName, data: data)
        
        // Verify table was created
        let tables = try db.listTables()
        XCTAssertTrue(tables.contains(tableName))
    }
}

/// Test class for Select module
final class SelectModule_OfflineTest: CuttDBTestCase {
    func testOfflineQuery() throws {
        // Test offline query functionality
        let tableName = "test_table"
        try db.createTable(name: tableName, columns: ["id", "name"])
        
        let result = try db.queryList(from: tableName)
        XCTAssertNotNil(result)
    }
}

final class SelectModule_PagedQueryTest: CuttDBTestCase {
    func testPagedQuery() throws {
        // Test paged query functionality
        let tableName = "test_table"
        try db.createTable(name: tableName, columns: ["id", "name"])
        
        let result = try db.queryList(from: tableName, page: 1, pageSize: 10)
        XCTAssertNotNil(result)
    }
}

/// Test class for InsertUpdate module
final class InsertUpdateModule_TransactionTest: CuttDBTestCase {
    func testTransaction() throws {
        // Test transaction functionality
        let tableName = "test_table"
        try db.createTable(name: tableName, columns: ["id", "name"])
        
        try db.transaction { db in
            try db.insert(table: tableName, data: ["id": "1", "name": "Test"])
            try db.update(table: tableName, data: ["name": "Updated"], where: "id = ?", parameters: ["1"])
        }
        
        let result = try db.queryList(from: tableName)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?["name"] as? String, "Updated")
    }
}

/// Test class for Align module
final class AlignModule_UpgradeTest: CuttDBTestCase {
    func testUpgrade() throws {
        // Test database upgrade functionality
        let oldVersion = 1
        let newVersion = 2
        
        try db.upgrade(from: oldVersion, to: newVersion)
        
        // Verify upgrade completed
        let version = try db.getVersion()
        XCTAssertEqual(version, newVersion)
    }
}

/// Test class for Mechanism module
final class MechanismModule_IndexTest: CuttDBTestCase {
    func testIndex() throws {
        // Test index functionality
        let tableName = "test_table"
        try db.createTable(name: tableName, columns: ["id", "name"])
        
        try db.createIndex(on: tableName, columns: ["name"])
        
        // Verify index exists
        let indexes = try db.listIndexes(for: tableName)
        XCTAssertTrue(indexes.contains("name"))
    }
}

/// Test suite for all CuttDB tests
class CuttDBTestSuite: XCTestCase {
    static var allTests: [(String, (XCTestCase) -> () throws -> Void)] {
        return [
            // Create Module Tests
            ("testTableDefinition", CreateModule_TableDefinitionTest.testTableDefinition),
            ("testSubTable", CreateModule_SubTableTest.testSubTable),
            ("testAutoCreate", CreateModule_AutoCreateTest.testAutoCreate),
            
            // Select Module Tests
            ("testOfflineQuery", SelectModule_OfflineTest.testOfflineQuery),
            ("testPagedQuery", SelectModule_PagedQueryTest.testPagedQuery),
            
            // InsertUpdate Module Tests
            ("testSQLOperations", InsertUpdateModule_SQLTest.testSQLOperations),
            ("testTransaction", InsertUpdateModule_TransactionTest.testTransaction),
            
            // Delete Module Tests
            ("testBatchDelete", DeleteModule_BatchTest.testBatchDelete),
            
            // Align Module Tests
            ("testUpgrade", AlignModule_UpgradeTest.testUpgrade),
            
            // Mechanism Module Tests
            ("testIndex", MechanismModule_IndexTest.testIndex)
        ]
    }
}

/// Test manager for running all tests
class CuttDBTestManager {
    static let shared = CuttDBTestManager()
    
    private init() {}
    
    /// Run all tests for a specific module
    func runTests(for module: TestModule) {
        print("Running tests for module: \(module.rawValue)")
        for testClass in module.testClasses {
            runTests(for: testClass)
        }
    }
    
    /// Run all tests for a specific test class
    func runTests(for testClass: XCTestCase.Type) {
        print("Running tests for class: \(testClass)")
        let testSuite = XCTestSuite(name: "\(testClass) Suite")
        let testCase = testClass.init()
        testSuite.addTest(testCase)
        testSuite.run()
    }
    
    /// Run all tests
    func runAllTests() {
        print("Running all tests")
        for module in TestModule.allCases {
            runTests(for: module)
        }
    }
}

#if DEBUG
/// Test class for running all tests
class CuttDBTestRunner: XCTestCase {
    /// Run all tests
    func testAll() {
        CuttDBTestManager.shared.runAllTests()
    }
    
    /// Run tests for a specific module
    func testModule(_ module: TestModule) {
        CuttDBTestManager.shared.runTests(for: module)
    }
    
    /// Run tests for a specific test class
    func testClass(_ testClass: XCTestCase.Type) {
        CuttDBTestManager.shared.runTests(for: testClass)
    }
}
#endif 