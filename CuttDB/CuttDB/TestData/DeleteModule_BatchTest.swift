import Foundation

/// 删除模块 - 批量删除测试
class DeleteModule_BatchTest: CuttDBTestCase {
    private let cuttDB: CuttDB
    
    override init() {
        self.cuttDB = CuttDB(dbName: "test_batch_delete.sqlite")
        super.init()
    }
    
    override func runTests() {
        print("Running DeleteModule_BatchTest...")
        
        // 创建测试数据
        let testData = [
            "tableName": "test_table",
            "conditions": ["id = 1", "id = 2", "id = 3"],
            "condition": "status = 'inactive'",
            "config": [
                "batch_size": 100,
                "max_retries": 3
            ]
        ]
        
        // 测试批量删除记录
        print("Testing batchDeleteRecords...")
        let batchResult = cuttDB.batchDelete(
            from: testData["tableName"] as! String,
            where: testData["conditions"] as! [String]
        )
        assert(batchResult > 0, "Batch delete records failed")
        
        // 测试带条件的批量删除
        print("Testing batchDeleteWithCondition...")
        let conditionResult = cuttDB.batchDelete(
            from: testData["tableName"] as! String,
            where: testData["condition"] as! String,
            batchSize: (testData["config"] as! [String: Any])["batch_size"] as! Int
        )
        assert(conditionResult > 0, "Batch delete with condition failed")
        
        // 测试事务中的批量删除
        print("Testing batchDeleteInTransaction...")
        let transactionResult = cuttDB.batchDeleteInTransaction(
            from: testData["tableName"] as! String,
            where: testData["conditions"] as! [String]
        )
        assert(transactionResult, "Batch delete in transaction failed")
        
        // 测试带重试的批量删除
        print("Testing batchDeleteWithRetry...")
        let retryResult = cuttDB.batchDeleteWithRetry(
            from: testData["tableName"] as! String,
            where: testData["conditions"] as! [String],
            maxRetries: (testData["config"] as! [String: Any])["max_retries"] as! Int
        )
        assert(retryResult, "Batch delete with retry failed")
        
        // 测试验证批量删除
        print("Testing validateBatchDelete...")
        let validateResult = cuttDB.validateBatchDelete(
            from: testData["tableName"] as! String,
            where: testData["conditions"] as! [String]
        )
        assert(validateResult, "Validate batch delete failed")
        
        print("DeleteModule_BatchTest completed successfully!")
    }
} 