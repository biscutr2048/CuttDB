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
            // 表定义测试
            CreateModule_TableDefinitionTest.Logic.testExtractTableDefinition()
            CreateModule_TableDefinitionTest.Logic.testValidateTableDefinition()
            CreateModule_TableDefinitionTest.Logic.testHandleComplexTypes()
            
            // 子表测试
            CreateModule_SubTableTest.Logic.testSubTableCreation()
            CreateModule_SubTableTest.Logic.testSubTableValidation()
            CreateModule_SubTableTest.Logic.testSubTableRelationships()
            
            // 自动创建测试
            CreateModule_AutoCreateTest.Logic.testBasicTableCreation()
            CreateModule_AutoCreateTest.Logic.testComplexTableCreation()
            CreateModule_AutoCreateTest.Logic.testExistingTableHandling()
            
        case .select:
            // 离线查询测试
            SelectModule_OfflineTest.Logic.testOfflineQuery()
            SelectModule_OfflineTest.Logic.testOfflineCache()
            SelectModule_OfflineTest.Logic.testOfflineValidation()
            
            // 分页查询测试
            SelectModule_PagedQueryTest.Logic.testBasicPagedQuery()
            SelectModule_PagedQueryTest.Logic.testPagedQueryWithConditions()
            SelectModule_PagedQueryTest.Logic.testPagedTotalCount()
            
        case .insertUpdate:
            // SQL生成测试
            InsertUpdateModule_SQLTest.Logic.testInsertSQLGeneration()
            InsertUpdateModule_SQLTest.Logic.testUpdateSQLGeneration()
            InsertUpdateModule_SQLTest.Logic.testUpsertSQLGeneration()
            
            // 事务处理测试
            InsertUpdateModule_TransactionTest.Logic.testTransactionHandling()
            InsertUpdateModule_TransactionTest.Logic.testBatchTransactionHandling()
            InsertUpdateModule_TransactionTest.Logic.testTransactionRollback()
            
        case .delete:
            // 数据老化测试
            DeleteModule_AgingTest.Logic.testSingleRecordAging()
            DeleteModule_AgingTest.Logic.testBatchRecordAging()
            DeleteModule_AgingTest.Logic.testTimeBasedAging()
            
            // 批量删除测试
            DeleteModule_BatchTest.Logic.testBatchDeleteRecords()
            DeleteModule_BatchTest.Logic.testConditionalBatchDelete()
            DeleteModule_BatchTest.Logic.testBatchDeleteTransaction()
            
        case .align:
            // 表结构升级测试
            AlignModule_UpgradeTest.Logic.testTableStructureUpgrade()
            AlignModule_UpgradeTest.Logic.testColumnAddition()
            AlignModule_UpgradeTest.Logic.testColumnModification()
            
            // 数据清理测试
            AlignModule_CleanupTest.Logic.testDataCleanup()
            AlignModule_CleanupTest.Logic.testBatchCleanup()
            AlignModule_CleanupTest.Logic.testCleanupValidation()
            
        case .listProperties:
            // 复杂列表测试
            ListPropertiesModule_ComplexTest.Logic.testComplexListHandling()
            ListPropertiesModule_ComplexTest.Logic.testNestedListHandling()
            ListPropertiesModule_ComplexTest.Logic.testListTableCreation()
            
        case .mechanism:
            // 索引管理测试
            MechanismModule_IndexTest.Logic.testCreateIndex()
            MechanismModule_IndexTest.Logic.testCreateCompositeIndex()
            MechanismModule_IndexTest.Logic.testIndexStatistics()
            
            // 响应处理测试
            MechanismModule_ResponseTest.Logic.testSuccessResponse()
            MechanismModule_ResponseTest.Logic.testErrorResponse()
            MechanismModule_ResponseTest.Logic.testResponseValidation()
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
    
    /// 运行单个测试用例
    /// - Parameters:
    ///   - module: 测试模块
    ///   - testCase: 测试用例名称
    static func runTestCase(module: TestModule, testCase: String) {
        print("\n=== Running Test Case: \(testCase) in \(module.rawValue) ===\n")
        
        switch module {
        case .create:
            switch testCase {
            case "testExtractTableDefinition":
                CreateModule_TableDefinitionTest.Logic.testExtractTableDefinition()
            case "testSubTableCreation":
                CreateModule_SubTableTest.Logic.testSubTableCreation()
            case "testBasicTableCreation":
                CreateModule_AutoCreateTest.Logic.testBasicTableCreation()
            default:
                print("Unknown test case: \(testCase)")
            }
            
        case .select:
            switch testCase {
            case "testOfflineQuery":
                SelectModule_OfflineTest.Logic.testOfflineQuery()
            case "testBasicPagedQuery":
                SelectModule_PagedQueryTest.Logic.testBasicPagedQuery()
            default:
                print("Unknown test case: \(testCase)")
            }
            
        case .insertUpdate:
            switch testCase {
            case "testInsertSQLGeneration":
                InsertUpdateModule_SQLTest.Logic.testInsertSQLGeneration()
            case "testTransactionHandling":
                InsertUpdateModule_TransactionTest.Logic.testTransactionHandling()
            default:
                print("Unknown test case: \(testCase)")
            }
            
        case .delete:
            switch testCase {
            case "testSingleRecordAging":
                DeleteModule_AgingTest.Logic.testSingleRecordAging()
            case "testBatchDeleteRecords":
                DeleteModule_BatchTest.Logic.testBatchDeleteRecords()
            default:
                print("Unknown test case: \(testCase)")
            }
            
        case .align:
            switch testCase {
            case "testTableStructureUpgrade":
                AlignModule_UpgradeTest.Logic.testTableStructureUpgrade()
            case "testDataCleanup":
                AlignModule_CleanupTest.Logic.testDataCleanup()
            default:
                print("Unknown test case: \(testCase)")
            }
            
        case .listProperties:
            switch testCase {
            case "testComplexListHandling":
                ListPropertiesModule_ComplexTest.Logic.testComplexListHandling()
            default:
                print("Unknown test case: \(testCase)")
            }
            
        case .mechanism:
            switch testCase {
            case "testCreateIndex":
                MechanismModule_IndexTest.Logic.testCreateIndex()
            case "testSuccessResponse":
                MechanismModule_ResponseTest.Logic.testSuccessResponse()
            default:
                print("Unknown test case: \(testCase)")
            }
        }
    }
}
#endif 
