import Foundation

/// 响应处理测试
class MechanismModule_ResponseTest: CuttDBTestCase {
    override func runTests() {
        print("\n=== 响应处理测试 ===")
        
        // 测试数据
        let testData = [
            "api": "/user",
            "method": "GET",
            "response": [
                "id": 1,
                "name": "Test User",
                "email": "test@example.com",
                "created_at": "2024-03-20T10:00:00Z"
            ]
        ]
        
        // 创建Mock服务
        let mockService = MockCuttDBService()
        
        // 测试响应处理
        print("\n测试响应处理")
        let handleResult = CuttDB.handleResponse(
            api: testData["api"] as! String,
            method: testData["method"] as! String,
            response: testData["response"] as! [String: Any],
            dbService: mockService
        )
        assert(handleResult, "响应处理失败")
        
        // 测试响应转换
        print("\n测试响应转换")
        let mapping = [
            "id": "user_id",
            "name": "user_name",
            "email": "user_email"
        ]
        let transformResult = CuttDB.transformResponse(
            testData["response"] as! [String: Any],
            mapping: mapping
        )
        assert(transformResult["user_id"] as? Int == 1, "响应转换失败")
        
        // 测试响应验证
        print("\n测试响应验证")
        let schema = [
            "id": "INTEGER",
            "name": "TEXT",
            "email": "TEXT",
            "created_at": "TEXT"
        ]
        let validateResult = CuttDB.validateResponse(
            testData["response"] as! [String: Any],
            schema: schema
        )
        assert(validateResult, "响应验证失败")
        
        // 测试响应日志
        print("\n测试响应日志")
        let logResult = CuttDB.logResponse(
            api: testData["api"] as! String,
            method: testData["method"] as! String,
            response: testData["response"] as! [String: Any],
            dbService: mockService
        )
        assert(logResult, "响应日志记录失败")
        
        print("\n=== 响应处理测试完成 ===")
    }
} 