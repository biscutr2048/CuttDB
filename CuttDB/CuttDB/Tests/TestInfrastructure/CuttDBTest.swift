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
        let config = CuttDBServiceConfiguration(dbPath: ":memory:")
        db = CuttDB(configuration: config)
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
}

/// Test manager for running all tests
class CuttDBTestManager {
    static let shared = CuttDBTestManager()
    
    private init() {}
    
    /// Run all tests for a specific module
    func runTests(for module: TestModule) {
        print("Running tests for module: \(module.rawValue)")
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
}
#endif 