import Foundation

/// 离线查询测试
class SelectModule_OfflineTest: CuttDBTestCase {
    override func runTests() {
        print("\n=== 离线查询测试 ===")
        
        // 测试数据
        let testData = [
            "api": "/user",
            "method": "GET",
            "listProperty": "orders",
            "property": "address",
            "expirationTime": 3600.0
        ]
        
        // 创建Mock服务
        let mockService = MockCuttDBService()
        
        // 测试恢复最近一次响应
        print("\n测试恢复最近一次响应")
        let lastResponse = CuttDB.restoreLastResponse(
            api: testData["api"] as! String,
            method: testData["method"] as! String,
            dbService: mockService
        )
        assert(lastResponse != nil, "恢复最近一次响应失败")
        
        // 测试恢复列表响应
        print("\n测试恢复列表响应")
        let listResponse = CuttDB.restoreListResponse(
            api: testData["api"] as! String,
            method: testData["method"] as! String,
            listProperty: testData["listProperty"] as! String,
            dbService: mockService
        )
        assert(!listResponse.isEmpty, "恢复列表响应失败")
        
        // 测试恢复子表响应
        print("\n测试恢复子表响应")
        let subTableResponse = CuttDB.restoreSubTableResponse(
            api: testData["api"] as! String,
            method: testData["method"] as! String,
            property: testData["property"] as! String,
            dbService: mockService
        )
        assert(!subTableResponse.isEmpty, "恢复子表响应失败")
        
        // 测试处理过期响应
        print("\n测试处理过期响应")
        let handleExpiredResult = CuttDB.handleExpiredResponse(
            api: testData["api"] as! String,
            method: testData["method"] as! String,
            expirationTime: testData["expirationTime"] as! TimeInterval,
            dbService: mockService
        )
        assert(handleExpiredResult, "处理过期响应失败")
        
        print("\n=== 离线查询测试完成 ===")
    }
} 