//
//  CuttDBTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import XCTest

/// Base test case class for all CuttDB tests
class CuttDBTestCase: XCTestCase {
    /// Database instance for testing
    var db: CuttDB!
    /// Mock service for testing
    var mockService: MockCuttDBService!
    
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
    
    /// Required initializer for XCTestCase
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Initialize test case
    init() {
        super.init()
    }
}

/// Test module enum for organizing tests
enum TestModule: String, CaseIterable {
    case create = "Create"
    case select = "Select"
    case insertUpdate = "InsertUpdate"
    case delete = "Delete"
    case align = "Align"
    case mechanism = "Mechanism"
    
    var testClasses: [CuttDBTestCase.Type] {
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
                DeleteModule_AgingTest.self,
                DeleteModule_BatchTest.self
            ]
        case .align:
            return [
                AlignModule_UpgradeTest.self,
                AlignModule_CleanupTest.self
            ]
        case .mechanism:
            return [
                MechanismModule_IndexTest.self,
                MechanismModule_ResponseTest.self
            ]
        }
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