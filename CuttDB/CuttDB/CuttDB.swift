import Foundation

/// 数据库业务对象管理
struct CuttDB {
    /// 生成请求索引词
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    /// - Returns: 拼接后的无符号索引词（只包含字母、数字和下划线）
    static func requestIndexKey(api: String, method: String) -> String {
        return "\(api)_\(method)".replacingOccurrences(of: "[^A-Za-z0-9_]", with: "", options: .regularExpression)
    }
}

// 示例测试
#if DEBUG
func testRequestIndexKey() {
    let key1 = CuttDB.requestIndexKey(api: "/user/list", method: "GET")
    print(key1) // userlist_GET
    let key2 = CuttDB.requestIndexKey(api: "order-detail", method: "post")
    print(key2) // orderdetail_post
}
#endif 