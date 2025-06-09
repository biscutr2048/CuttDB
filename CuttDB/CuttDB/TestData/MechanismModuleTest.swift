import Foundation

/// 机制模块测试
struct MechanismModuleTest {
    /// 测试数据
    struct Data {
        static let apiTestCases: [(path: String, method: String, expected: String)] = [
            ("/user/list", "GET", "userlist_GET"),
            ("order-detail", "post", "orderdetail_post"),
            ("user/profile/123", "PUT", "userprofile123_PUT")
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        /// 测试请求索引词生成
        static func testRequestIndexKey() {
            for (index, testCase) in Data.apiTestCases.enumerated() {
                let key = CuttDB.requestIndexKey(api: testCase.path, method: testCase.method)
                print("Test \(index + 1) - \(testCase.path):", key)
                assert(key == testCase.expected, "Expected \(testCase.expected) but got \(key)")
            }
        }
    }
} 