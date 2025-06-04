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
    
    /// 从 JSON 结构提取表格定义
    /// - Parameter json: 任意 JSON 对象（通常为 [String: Any]）
    /// - Returns: [(字段名, 字段类型)]，嵌套结构类型为 TEXT，内容为 json 字符串
    static func extractTableDefinition(from json: Any) -> [(name: String, type: String)] {
        guard let dict = json as? [String: Any] else { return [] }
        var fields: [(String, String)] = []
        for (key, value) in dict {
            if value is String || value is Int || value is Double || value is Bool || value is NSNull {
                fields.append((key, "TEXT"))
            } else if value is [Any] || value is [String: Any] {
                // 嵌套结构直接用 TEXT 存 json 字符串
                fields.append((key, "TEXT"))
            } else {
                // 其他未知类型也按 TEXT 处理
                fields.append((key, "TEXT"))
            }
        }
        return fields
    }
    
    /// 根据响应数据自动提取表定义、自动识别主键并判断主键是否存在，生成SQL语句（insert或update），表名自动用requestIndexKey生成
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - json: 一条response的json数据（[String: Any]）
    ///   - dbService: CuttDBService实例，用于主键存在性判断
    /// - Returns: 生成的SQL语句字符串
    static func generateSQL(api: String, method: String, json: [String: Any], dbService: CuttDBService) -> String? {
        let tableName = requestIndexKey(api: api, method: method)
        let tableDefinition = extractTableDefinition(from: json)
        let fields = tableDefinition.map { $0.name }
        var values: [String: Any] = [:]
        for field in fields {
            if let value = json[field] {
                // 嵌套结构转为json字符串
                if let dict = value as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: dict),
                   let jsonStr = String(data: data, encoding: .utf8) {
                    values[field] = jsonStr
                } else if let arr = value as? [Any],
                          let data = try? JSONSerialization.data(withJSONObject: arr),
                          let jsonStr = String(data: data, encoding: .utf8) {
                    values[field] = jsonStr
                } else {
                    values[field] = value
                }
            }
        }
        // 自动识别主键字段，优先id，其次以id结尾
        let primaryKey = fields.first(where: { $0.lowercased() == "id" }) ?? fields.first(where: { $0.lowercased().hasSuffix("id") })
        var keyExists = false
        var pkValue: Any? = nil
        if let pk = primaryKey, let v = values[pk] {
            pkValue = v
            keyExists = dbService.primaryKeyExists(tableName: tableName, primaryKey: pk, value: v)
        }
        if keyExists, let pk = primaryKey, let v = pkValue {
            // update语句
            let setClause = fields.filter { $0 != pk && values[$0] != nil }.map { "\($0) = '" + String(describing: values[$0]!) + "'" }.joined(separator: ", ")
            let sql = "UPDATE \(tableName) SET \(setClause) WHERE \(pk) = '" + String(describing: v) + "'"
            return sql
        } else {
            // insert语句
            let insertFields = fields.filter { values[$0] != nil }
            let insertValues = insertFields.map { "'" + String(describing: values[$0]!) + "'" }
            let sql = "INSERT INTO \(tableName) (\(insertFields.joined(separator: ", "))) VALUES (\(insertValues.joined(separator: ", ")))"
            return sql
        }
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

func testExtractTableDefinition() {
    let json: [String: Any] = [
        "id": 123,
        "name": "Alice",
        "profile": [
            "age": 30,
            "city": "Beijing",
            "contact": [
                "email": "alice@example.com",
                "phone": "123456"
            ]
        ],
        "tags": ["swift", "macos"],
        "meta": NSNull(),
        "history": [
            [
                "date": "2024-06-01",
                "action": "login"
            ],
            [
                "date": "2024-06-02",
                "action": "logout"
            ]
        ]
    ]
    let def = CuttDB.extractTableDefinition(from: json)
    print(def)
    // 期望输出: [("id", "TEXT"), ("name", "TEXT"), ("profile", "TEXT"), ("tags", "TEXT"), ("meta", "TEXT"), ("history", "TEXT")]
}
#endif 
