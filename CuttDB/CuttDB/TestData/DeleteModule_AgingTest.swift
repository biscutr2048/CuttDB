import Foundation

/// 删除模块 - 数据老化测试
class DeleteModule_AgingTest: CuttDBTestCase {
    override func runTests() {
        print("\n=== 数据老化测试 ===")
        
        // 测试数据
        let activeRecords: [[String: Any]] = [
            ["id": 1, "name": "Record 1", "status": "active", "created_at": "2024-01-01"],
            ["id": 2, "name": "Record 2", "status": "active", "created_at": "2024-01-02"],
            ["id": 3, "name": "Record 3", "status": "active", "created_at": "2024-01-03"]
        ]
        
        let agedRecords: [[String: Any]] = [
            ["id": 4, "name": "Record 4", "status": "aged", "created_at": "2023-12-01"],
            ["id": 5, "name": "Record 5", "status": "aged", "created_at": "2023-12-02"]
        ]
        
        let agingRules: [String: Any] = [
            "status": "aged",
            "condition": "created_at < '2024-01-01'",
            "batch_size": 2
        ]
        
        // 创建Mock服务
        let mockService = MockCuttDBService()
        
        // 测试单条记录老化
        print("\n测试单条记录老化")
        mockService.setMockData(tableName: "records", data: activeRecords)
        
        let updateSQL = "UPDATE records SET status = 'aged' WHERE id = 1"
        let updateResult = mockService.execute(sql: updateSQL)
        assert(updateResult, "更新记录状态失败")
        
        let verifySQL = "SELECT * FROM records WHERE id = 1"
        if let updatedRecord = mockService.query(sql: verifySQL)?.first {
            assert(updatedRecord["status"] as? String == "aged", "记录应该被标记为已老化")
        } else {
            assert(false, "无法验证更新结果")
        }
        
        // 测试批量记录老化
        print("\n测试批量记录老化")
        mockService.setMockData(tableName: "records", data: activeRecords)
        
        let batchUpdateSQL = "UPDATE records SET status = 'aged' WHERE created_at < '2024-01-02'"
        let batchResult = mockService.execute(sql: batchUpdateSQL)
        assert(batchResult, "批量更新记录失败")
        
        let batchVerifySQL = "SELECT * FROM records WHERE status = 'aged'"
        if let agedRecords = mockService.query(sql: batchVerifySQL) {
            assert(agedRecords.count == 1, "应该有1条老化记录")
        } else {
            assert(false, "无法验证批量更新结果")
        }
        
        // 测试基于时间的自动老化
        print("\n测试基于时间的自动老化")
        mockService.setMockData(tableName: "records", data: activeRecords)
        
        let timeBasedSQL = "UPDATE records SET status = 'aged' WHERE created_at < date('now', '-30 days')"
        let timeResult = mockService.execute(sql: timeBasedSQL)
        assert(timeResult, "基于时间的更新失败")
        
        // 测试老化数据清理
        print("\n测试老化数据清理")
        let cleanupResult = CuttDB.cleanupAgedData(
            tableName: "records",
            ageField: "created_at",
            ageThreshold: "2023-12-31",
            dbService: mockService
        )
        assert(cleanupResult > 0, "老化数据清理失败")
        
        // 测试老化规则应用
        print("\n测试老化规则应用")
        let ruleResult = CuttDB.applyAgingRules(
            tableName: "records",
            rules: agingRules,
            dbService: mockService
        )
        assert(ruleResult, "应用老化规则失败")
        
        // 测试批量老化配置
        print("\n测试批量老化配置")
        let configResult = CuttDB.configureBatchAging(
            tableName: "records",
            config: agingRules,
            dbService: mockService
        )
        assert(configResult, "配置批量老化失败")
        
        print("\n=== 数据老化测试完成 ===")
    }
} 