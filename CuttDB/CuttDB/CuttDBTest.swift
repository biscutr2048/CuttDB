//
//  CuttDBTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

#if DEBUG
/// CuttDB测试控制器
struct CuttDBTest {
    /// 测试模块枚举
    enum TestModule: String, CaseIterable {
        case create = "Create Module"
        case select = "Select Module"
        case insertUpdate = "Insert/Update Module"
        case delete = "Delete Module"
        case align = "Align Module"
        case listProperties = "List Properties Module"
        case mechanism = "Mechanism Module"
    }
    
    /// 运行指定模块的测试
    /// - Parameter module: 要测试的模块
    static func runTest(for module: TestModule) {
        print("\n=== Testing \(module.rawValue) ===\n")
        
        switch module {
        case .create:
            CreateModuleTest.Logic.testExtractTableDefinition()
            CreateModuleTest.Logic.testAutoCreateTable()
            CreateModuleTest.Logic.testAutoCreateIndex()
            CreateModuleTest.Logic.testHandleNestedListProperties()
            
        case .select:
            SelectModuleTest.Logic.testLoadResponseOffline()
            SelectModuleTest.Logic.testSelectObjectSQL()
            SelectModuleTest.Logic.testSelectListPagedSQL()
            SelectModuleTest.Logic.testSelectByBusinessKey()
            
        case .insertUpdate:
            InsertUpdateModuleTest.Logic.testGenerateSQL()
            
        case .delete:
            DeleteModuleTest.Logic.testUpdateToAged()
            DeleteModuleTest.Logic.testBatchUpdateToAged()
            DeleteModuleTest.Logic.testAutoCleanupAgedData()
            
        case .align:
            AlignModuleTest.Logic.testUpgradeTableStructure()
            AlignModuleTest.Logic.testCleanupMissingData()
            AlignModuleTest.Logic.testDebugDataValidation()
            
        case .listProperties:
            ListPropertiesModuleTest.Logic.testHandleListProperties()
            
        case .mechanism:
            MechanismModuleTest.Logic.testRequestIndexKey()
        }
    }
    
    /// 运行所有测试
    static func runAllTests() {
        print("\n=== Running All CuttDB Tests ===\n")
        
        for module in TestModule.allCases {
            runTest(for: module)
        }
        
        print("\n=== All Tests Completed ===\n")
    }
    
    /// 运行指定模块的测试
    /// - Parameter modules: 要测试的模块数组
    static func runTests(for modules: [TestModule]) {
        print("\n=== Running Selected CuttDB Tests ===\n")
        
        for module in modules {
            runTest(for: module)
        }
        
        print("\n=== Selected Tests Completed ===\n")
    }
}
#endif 
