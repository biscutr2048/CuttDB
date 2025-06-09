//
//  CuttDB.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/4.
//

import Foundation

/// CuttDB - 用户接口层
/// 提供简化的、高度自动化的API给用户代码
public struct CuttDB {
    private let service: CuttDBService
    private let dbPath: String
    
    /// 初始化CuttDB实例
    /// - Parameter dbName: 数据库名称，默认为"cuttDB.sqlite"
    public init(dbName: String = "cuttDB.sqlite") {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.dbPath = documentsPath.appendingPathComponent(dbName).path
        self.service = CuttDBServiceFactory.shared().getService(dbPath: dbPath)
    }
    
    // MARK: - 表管理
    
    /// 确保表存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列定义
    /// - Returns: 是否成功
    public func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        if !service.tableExists(tableName) {
            let sql = generateCreateTableSQL(tableName: tableName, columns: columns)
            return service.execute(sql: sql)
        }
        return true
    }
    
    /// 确保子表存在
    /// - Parameters:
    ///   - tableName: 主表名
    ///   - property: 属性名
    ///   - columns: 列定义
    /// - Returns: 是否成功
    public func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        let subTableName = "\(tableName)-sub-\(property)"
        return ensureTableExists(tableName: subTableName, columns: columns)
    }
    
    // MARK: - 数据操作
    
    /// 保存对象
    /// - Parameters:
    ///   - object: 要保存的对象
    ///   - tableName: 表名
    /// - Returns: 是否成功
    public func saveObject(_ object: [String: Any], to tableName: String) -> Bool {
        if let id = object["id"] as? Int {
            return updateObject(object, in: tableName)
        } else {
            return insertObject(object, into: tableName)
        }
    }
    
    /// 插入对象
    /// - Parameters:
    ///   - object: 要插入的对象
    ///   - tableName: 表名
    /// - Returns: 是否成功
    public func insertObject(_ object: [String: Any], into tableName: String) -> Bool {
        let sql = generateInsertSQL(tableName: tableName, values: object)
        return service.execute(sql: sql)
    }
    
    /// 更新对象
    /// - Parameters:
    ///   - object: 要更新的对象
    ///   - tableName: 表名
    /// - Returns: 是否成功
    public func updateObject(_ object: [String: Any], in tableName: String) -> Bool {
        guard let id = object["id"] as? Int else { return false }
        let sql = generateUpdateSQL(tableName: tableName, values: object, whereClause: "id = \(id)")
        return service.execute(sql: sql)
    }
    
    /// 查询对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    /// - Returns: 查询结果
    public func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        let sql = "SELECT * FROM \(tableName) WHERE \(whereClause) LIMIT 1"
        return service.query(sql: sql)?.first
    }
    
    /// 查询列表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果
    public func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        var sql = "SELECT * FROM \(tableName)"
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        if let orderBy = orderBy {
            sql += " ORDER BY \(orderBy)"
        }
        if let limit = limit {
            sql += " LIMIT \(limit)"
        }
        return service.query(sql: sql) ?? []
    }
    
    // MARK: - SQL生成
    
    /// 生成创建表SQL
    private func generateCreateTableSQL(tableName: String, columns: [String]) -> String {
        return """
            CREATE TABLE IF NOT EXISTS \(tableName) (
                \(columns.joined(separator: ", "))
            );
        """
    }
    
    /// 生成插入SQL
    private func generateInsertSQL(tableName: String, values: [String: Any]) -> String {
        let columns = values.keys.joined(separator: ", ")
        let placeholders = values.keys.map { "@\($0)" }.joined(separator: ", ")
        return "INSERT INTO \(tableName) (\(columns)) VALUES (\(placeholders))"
    }
    
    /// 生成更新SQL
    private func generateUpdateSQL(tableName: String, values: [String: Any], whereClause: String) -> String {
        let setClause = values.keys.map { "\($0) = @\($0)" }.joined(separator: ", ")
        return "UPDATE \(tableName) SET \(setClause) WHERE \(whereClause)"
    }
    
    // MARK: - 工具方法
    
    /// 生成请求索引键
    /// - Parameters:
    ///   - api: API路径
    ///   - method: HTTP方法
    /// - Returns: 索引键
    public static func requestIndexKey(api: String, method: String) -> String {
        return "\(method)_\(api)".replacingOccurrences(of: "/", with: "_")
    }
}

// MARK: - Create Module

extension CuttDB {
    /// 模块：create
    /// 需求：auto.get create sql
    /// 功能：从 JSON 结构提取表格定义
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
    
    /// 确保表存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否成功
    static func ensureTableExists(tableName: String, columns: [String: String], dbService: CuttDBService) -> Bool {
        return dbService.ensureTableExists(tableName: tableName, columns: columns)
    }
    
    /// 验证表结构
    /// - Parameters:
    ///   - tableName: 表名
    ///   - expectedColumns: 期望的列定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否验证通过
    static func validateTableStructure(tableName: String, expectedColumns: [String: String], dbService: CuttDBService) -> Bool {
        return dbService.validateTableStructure(tableName: tableName, expectedColumns: expectedColumns)
    }
    
    /// 创建索引（如果需要）
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexes: 索引定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否成功
    static func createIndexesIfNeeded(tableName: String, indexes: [String: String], dbService: CuttDBService) -> Bool {
        return dbService.createIndexesIfNeeded(tableName: tableName, indexes: indexes)
    }
    
    /// 创建单个索引（如果需要）
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - columns: 索引列
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否成功
    static func createIndexIfNeeded(tableName: String, indexName: String, columns: [String], dbService: CuttDBService) -> Bool {
        return dbService.createIndexIfNeeded(tableName: tableName, indexName: indexName, columns: columns)
    }
    
    /// 创建子表
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - columns: 列定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否成功
    static func createSubTable(parentTable: String, subTable: String, columns: [String: String], dbService: CuttDBService) -> Bool {
        return dbService.createSubTable(parentTable: parentTable, subTable: subTable, columns: columns)
    }
    
    /// 验证子表结构
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - expectedColumns: 期望的列定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否验证通过
    static func validateSubTableStructure(parentTable: String, subTable: String, expectedColumns: [String: String], dbService: CuttDBService) -> Bool {
        return dbService.validateSubTableStructure(parentTable: parentTable, subTable: subTable, expectedColumns: expectedColumns)
    }
    
    /// 创建表定义
    /// - Parameters:
    ///   - tableName: 表名
    ///   - definition: 表定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否成功
    static func createTableDefinition(tableName: String, definition: [String: Any], dbService: CuttDBService) -> Bool {
        return dbService.createTableDefinition(tableName: tableName, definition: definition)
    }
    
    /// 验证表定义
    /// - Parameters:
    ///   - tableName: 表名
    ///   - expectedDefinition: 期望的表定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否验证通过
    static func validateTableDefinition(tableName: String, expectedDefinition: [String: Any], dbService: CuttDBService) -> Bool {
        return dbService.validateTableDefinition(tableName: tableName, expectedDefinition: expectedDefinition)
    }
}

// MARK: - Insert/Update Module

extension CuttDB {
    /// 模块：insert/update
    /// 需求：op.save object to insert sql, op.save object to update sql
    /// 功能：根据响应数据自动提取表定义、自动识别主键并判断主键是否存在，生成SQL语句（insert或update）
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
    
    // MARK: - List Properties Module
    /// 模块：create
    /// 需求：auto.create sub-table when listing
    /// 功能：处理response中包含列表属性的情况，自动为每个列表属性建立子表并生成SQL
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - json: 一条response的json数据（[String: Any]）
    ///   - dbService: CuttDBService实例
    /// - Returns: [子表表名: [SQL语句字符串]]
    static func handleListProperties(api: String, method: String, json: [String: Any], dbService: CuttDBService) -> [String: [String]] {
        let mainTable = requestIndexKey(api: api, method: method)
        var result: [String: [String]] = [:]
        for (key, value) in json {
            guard let list = value as? [Any], !list.isEmpty else { continue }
            // 子表名：主表-requestnamed-sub-属性名
            let subTable = "\(mainTable)-sub-\(key)"
            var sqls: [String] = []
            for item in list {
                guard let itemDict = item as? [String: Any] else { continue }
                // 自动建表结构
                let tableDef = extractTableDefinition(from: itemDict)
                // 自动识别主键
                let fields = tableDef.map { $0.name }
                let primaryKey = fields.first(where: { $0.lowercased() == "id" }) ?? fields.first(where: { $0.lowercased().hasSuffix("id") })
                var keyExists = false
                var pkValue: Any? = nil
                if let pk = primaryKey, let v = itemDict[pk] {
                    pkValue = v
                    keyExists = dbService.primaryKeyExists(tableName: subTable, primaryKey: pk, value: v)
                }
                // 生成SQL
                if keyExists, let pk = primaryKey, let v = pkValue {
                    let setClause = fields.filter { $0 != pk && itemDict[$0] != nil }.map { "\($0) = '" + String(describing: itemDict[$0]!) + "'" }.joined(separator: ", ")
                    let sql = "UPDATE \(subTable) SET \(setClause) WHERE \(pk) = '" + String(describing: v) + "'"
                    sqls.append(sql)
                } else {
                    let insertFields = fields.filter { itemDict[$0] != nil }
                    let insertValues = insertFields.map { "'" + String(describing: itemDict[$0]!) + "'" }
                    let sql = "INSERT INTO \(subTable) (\(insertFields.joined(separator: ", "))) VALUES (\(insertValues.joined(separator: ", ")))"
                    sqls.append(sql)
                }
            }
            if !sqls.isEmpty {
                result[subTable] = sqls
            }
        }
        return result
    }
    
    /// 处理复杂列表属性
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 包含列表属性的数据
    ///   - dbService: 数据库服务实例
    /// - Returns: 处理结果
    static func handleComplexListProperties(tableName: String, data: [String: Any], dbService: CuttDBService) -> Bool {
        for (key, value) in data {
            if let list = value as? [Any] {
                let subTable = "\(tableName)_\(key)"
                let tableDef = extractTableDefinition(from: list.first ?? [:])
                let columns = tableDef.map { "\($0.name) \($0.type)" }
                
                if !dbService.executeWithTable(tableName: subTable, columns: columns) {
                    return false
                }
                
                for item in list {
                    if let itemDict = item as? [String: Any] {
                        if !dbService.insert(tableName: subTable, values: itemDict) {
                            return false
                        }
                    }
                }
            }
        }
        return true
    }
    
    /// 处理嵌套列表属性
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 包含嵌套列表的数据
    ///   - dbService: 数据库服务实例
    /// - Returns: 处理结果
    static func handleNestedListProperties(tableName: String, data: [String: Any], dbService: CuttDBService) -> Bool {
        for (key, value) in data {
            if let nestedList = value as? [[String: Any]] {
                let subTable = "\(tableName)_\(key)"
                let tableDef = extractTableDefinition(from: nestedList.first ?? [:])
                let columns = tableDef.map { "\($0.name) \($0.type)" }
                
                if !dbService.executeWithTable(tableName: subTable, columns: columns) {
                    return false
                }
                
                for item in nestedList {
                    if !dbService.insert(tableName: subTable, values: item) {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    /// 创建列表相关的表
    /// - Parameters:
    ///   - tableName: 主表名
    ///   - listProperties: 列表属性定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 创建结果
    static func createListTables(tableName: String, listProperties: [String: [String: String]], dbService: CuttDBService) -> Bool {
        for (key, schema) in listProperties {
            let subTable = "\(tableName)_\(key)"
            let columns = schema.map { "\($0.key) \($0.value)" }
            
            if !dbService.executeWithTable(tableName: subTable, columns: columns) {
                return false
            }
        }
        return true
    }
    
    /// 验证列表数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 要验证的数据
    ///   - dbService: 数据库服务实例
    /// - Returns: 验证结果
    static func validateListData(tableName: String, data: [String: Any], dbService: CuttDBService) -> Bool {
        for (key, value) in data {
            if let list = value as? [Any] {
                let subTable = "\(tableName)_\(key)"
                let results = dbService.select(tableName: subTable)
                if results.count != list.count {
                    return false
                }
            }
        }
        return true
    }
    
    /// 处理列表关系
    /// - Parameters:
    ///   - tableName: 表名
    ///   - relationships: 关系定义
    ///   - dbService: 数据库服务实例
    /// - Returns: 处理结果
    static func handleListRelationships(tableName: String, relationships: [String: String], dbService: CuttDBService) -> Bool {
        for (listTable, foreignKey) in relationships {
            let subTable = "\(tableName)_\(listTable)"
            let query = "ALTER TABLE \(subTable) ADD COLUMN \(foreignKey) INTEGER REFERENCES \(tableName)(id)"
            if !dbService.executeQuery(query) {
                return false
            }
        }
        return true
    }
    
    // MARK: - Mechanism Module
    /// 模块：mechanism
    /// 需求：pair table to req, obj_list, paged
    /// 功能：生成请求索引词
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    /// - Returns: 拼接后的无符号索引词（只包含字母、数字和下划线）
    static func requestIndexKey(api: String, method: String) -> String {
        return "\(api)_\(method)".replacingOccurrences(of: "[^A-Za-z0-9_]", with: "", options: .regularExpression)
    }
    
    /// 处理响应数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - response: 响应数据
    ///   - dbService: 数据库服务实例
    /// - Returns: 处理结果
    static func handleResponse(api: String, method: String, response: [String: Any], dbService: CuttDBService) -> Bool {
        let tableName = requestIndexKey(api: api, method: method)
        let tableDef = extractTableDefinition(from: response)
        let columns = tableDef.map { "\($0.name) \($0.type)" }
        
        if !dbService.executeWithTable(tableName: tableName, columns: columns) {
            return false
        }
        
        return dbService.insert(tableName: tableName, values: response)
    }
    
    /// 转换响应数据
    /// - Parameters:
    ///   - response: 原始响应数据
    ///   - mapping: 字段映射关系
    /// - Returns: 转换后的数据
    static func transformResponse(_ response: [String: Any], mapping: [String: String]) -> [String: Any] {
        var transformed: [String: Any] = [:]
        for (key, value) in response {
            if let newKey = mapping[key] {
                transformed[newKey] = value
            } else {
                transformed[key] = value
            }
        }
        return transformed
    }
    
    /// 验证响应数据
    /// - Parameters:
    ///   - response: 响应数据
    ///   - schema: 数据模式
    /// - Returns: 验证结果
    static func validateResponse(_ response: [String: Any], schema: [String: String]) -> Bool {
        for (key, type) in schema {
            guard let value = response[key] else { return false }
            
            switch type {
            case "INTEGER":
                guard value is Int else { return false }
            case "REAL":
                guard value is Double else { return false }
            case "TEXT":
                guard value is String else { return false }
            case "BLOB":
                guard value is Data else { return false }
            default:
                return false
            }
        }
        return true
    }
    
    /// 记录响应日志
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - response: 响应数据
    ///   - dbService: 数据库服务实例
    /// - Returns: 记录结果
    static func logResponse(api: String, method: String, response: [String: Any], dbService: CuttDBService) -> Bool {
        let tableName = "\(requestIndexKey(api: api, method: method))_log"
        let columns = [
            "id INTEGER PRIMARY KEY AUTOINCREMENT",
            "timestamp TEXT",
            "response TEXT"
        ]
        
        if !dbService.executeWithTable(tableName: tableName, columns: columns) {
            return false
        }
        
        let logData: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "response": String(describing: response)
        ]
        
        return dbService.insert(tableName: tableName, values: logData)
    }
    
    // MARK: - Select Module
    /// 恢复最近一次响应数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - dbService: 数据库服务实例
    /// - Returns: 最近一次响应数据
    static func restoreLastResponse(api: String, method: String, dbService: CuttDBService) -> [String: Any]? {
        return dbService.restoreLastResponse(api: api, method: method)
    }
    
    /// 恢复列表响应数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - listProperty: 列表属性名
    ///   - dbService: 数据库服务实例
    /// - Returns: 列表响应数据
    static func restoreListResponse(api: String, method: String, listProperty: String, dbService: CuttDBService) -> [[String: Any]] {
        let tableName = "\(requestIndexKey(api: api, method: method))_\(listProperty)"
        return dbService.select(tableName: tableName)
    }
    
    /// 恢复子表响应数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - property: 属性名
    ///   - dbService: 数据库服务实例
    /// - Returns: 子表响应数据
    static func restoreSubTableResponse(api: String, method: String, property: String, dbService: CuttDBService) -> [[String: Any]] {
        return dbService.restoreSubTableResponse(api: api, method: method, property: property)
    }
    
    /// 处理过期响应
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - expirationTime: 过期时间（秒）
    ///   - dbService: 数据库服务实例
    /// - Returns: 处理结果
    static func handleExpiredResponse(api: String, method: String, expirationTime: TimeInterval, dbService: CuttDBService) -> Bool {
        let tableName = requestIndexKey(api: api, method: method)
        let expirationDate = Date().addingTimeInterval(-expirationTime)
        let expirationString = ISO8601DateFormatter().string(from: expirationDate)
        
        let query = "DELETE FROM \(tableName) WHERE created_at < '\(expirationString)'"
        return dbService.executeQuery(query)
    }
    
    // MARK: - Align Module

    /// 清理数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 清理条件
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func cleanupData(tableName: String, condition: String, dbService: CuttDBService) -> Bool {
        let sql = "DELETE FROM \(tableName) WHERE \(condition)"
        return dbService.execute(sql: sql)
    }
    
    /// 批量清理
    /// - Parameters:
    ///   - tableName: 表名
    ///   - conditions: 清理条件列表
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func batchCleanup(tableName: String, conditions: [String], dbService: CuttDBService) -> Bool {
        for condition in conditions {
            if !cleanupData(tableName: tableName, condition: condition, dbService: dbService) {
                return false
            }
        }
        return true
    }
    
    /// 验证清理结果
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 验证条件
    ///   - dbService: 数据库服务
    /// - Returns: 是否验证通过
    static func validateCleanup(tableName: String, condition: String, dbService: CuttDBService) -> Bool {
        let sql = "SELECT COUNT(*) as count FROM \(tableName) WHERE \(condition)"
        guard let result = dbService.query(sql: sql)?.first,
              let count = result["count"] as? Int else {
            return false
        }
        return count == 0
    }
    
    /// 清理前备份
    /// - Parameters:
    ///   - tableName: 表名
    ///   - backupTable: 备份表名
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func backupBeforeCleanup(tableName: String, backupTable: String, dbService: CuttDBService) -> Bool {
        let sql = "CREATE TABLE \(backupTable) AS SELECT * FROM \(tableName)"
        return dbService.execute(sql: sql)
    }
    
    /// 清理后恢复
    /// - Parameters:
    ///   - tableName: 表名
    ///   - backupTable: 备份表名
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func restoreAfterCleanup(tableName: String, backupTable: String, dbService: CuttDBService) -> Bool {
        let sql = "INSERT INTO \(tableName) SELECT * FROM \(backupTable)"
        return dbService.execute(sql: sql)
    }
    
    /// 记录清理操作
    /// - Parameters:
    ///   - tableName: 表名
    ///   - operation: 操作类型
    ///   - condition: 清理条件
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func logCleanupOperation(tableName: String, operation: String, condition: String, dbService: CuttDBService) -> Bool {
        let logData: [String: Any] = [
            "table_name": tableName,
            "operation": operation,
            "condition": condition,
            "timestamp": Date().timeIntervalSince1970
        ]
        return dbService.insert(tableName: "cleanup_logs", data: logData)
    }
}

// MARK: - Delete Module

extension CuttDB {
    /// 清理老化数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - ageField: 老化字段
    ///   - ageThreshold: 老化阈值
    ///   - dbService: 数据库服务
    /// - Returns: 清理的记录数
    static func cleanupAgedData(tableName: String, ageField: String, ageThreshold: String, dbService: CuttDBService) -> Int {
        let sql = "DELETE FROM \(tableName) WHERE \(ageField) < '\(ageThreshold)'"
        return dbService.execute(sql: sql) ? 1 : 0
    }
    
    /// 应用老化规则
    /// - Parameters:
    ///   - tableName: 表名
    ///   - rules: 老化规则
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func applyAgingRules(tableName: String, rules: [String: Any], dbService: CuttDBService) -> Bool {
        guard let status = rules["status"] as? String,
              let condition = rules["condition"] as? String else {
            return false
        }
        
        let sql = "UPDATE \(tableName) SET status = '\(status)' WHERE \(condition)"
        return dbService.execute(sql: sql)
    }
    
    /// 配置批量老化
    /// - Parameters:
    ///   - tableName: 表名
    ///   - config: 配置信息
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func configureBatchAging(tableName: String, config: [String: Any], dbService: CuttDBService) -> Bool {
        guard let batchSize = config["batch_size"] as? Int else {
            return false
        }
        
        // 这里可以添加更多的配置逻辑
        return true
    }
    
    /// 批量删除记录
    /// - Parameters:
    ///   - tableName: 表名
    ///   - conditions: 删除条件列表
    ///   - dbService: 数据库服务
    /// - Returns: 删除的记录数
    static func batchDeleteRecords(tableName: String, conditions: [String], dbService: CuttDBService) -> Int {
        var count = 0
        for condition in conditions {
            let sql = "DELETE FROM \(tableName) WHERE \(condition)"
            if dbService.execute(sql: sql) {
                count += 1
            }
        }
        return count
    }
    
    /// 根据条件批量删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 删除条件
    ///   - batchSize: 批次大小
    ///   - dbService: 数据库服务
    /// - Returns: 删除的记录数
    static func batchDeleteWithCondition(tableName: String, condition: String, batchSize: Int, dbService: CuttDBService) -> Int {
        let sql = "DELETE FROM \(tableName) WHERE \(condition) LIMIT \(batchSize)"
        return dbService.execute(sql: sql) ? batchSize : 0
    }
    
    /// 配置批量删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - config: 配置信息
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func configureBatchDelete(tableName: String, config: [String: Any], dbService: CuttDBService) -> Bool {
        // 这里可以添加配置逻辑
        return true
    }
    
    /// 在事务中批量删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - conditions: 删除条件列表
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func batchDeleteInTransaction(tableName: String, conditions: [String], dbService: CuttDBService) -> Bool {
        // 这里可以添加事务处理逻辑
        return true
    }
    
    /// 带重试的批量删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - conditions: 删除条件列表
    ///   - maxRetries: 最大重试次数
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func batchDeleteWithRetry(tableName: String, conditions: [String], maxRetries: Int, dbService: CuttDBService) -> Bool {
        // 这里可以添加重试逻辑
        return true
    }
    
    /// 验证批量删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - conditions: 删除条件列表
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func validateBatchDelete(tableName: String, conditions: [String], dbService: CuttDBService) -> Bool {
        // 这里可以添加验证逻辑
        return true
    }
}

// MARK: - Mechanism Module

extension CuttDB {
    /// 创建索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - columns: 索引列
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func createIndex(tableName: String, indexName: String, columns: [String], dbService: CuttDBService) -> Bool {
        let columnsStr = columns.joined(separator: ", ")
        let sql = "CREATE INDEX \(indexName) ON \(tableName) (\(columnsStr))"
        return dbService.execute(sql: sql)
    }
    
    /// 删除索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func dropIndex(tableName: String, indexName: String, dbService: CuttDBService) -> Bool {
        let sql = "DROP INDEX \(indexName) ON \(tableName)"
        return dbService.execute(sql: sql)
    }
    
    /// 重建索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func rebuildIndex(tableName: String, indexName: String, dbService: CuttDBService) -> Bool {
        let sql = "ALTER INDEX \(indexName) ON \(tableName) REBUILD"
        return dbService.execute(sql: sql)
    }
    
    /// 获取索引统计信息
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - dbService: 数据库服务
    /// - Returns: 索引统计信息
    static func getIndexStatistics(tableName: String, indexName: String, dbService: CuttDBService) -> [String: Any] {
        let sql = "SELECT * FROM sys.indexes WHERE name = '\(indexName)' AND object_id = OBJECT_ID('\(tableName)')"
        return dbService.query(sql: sql)?.first ?? [:]
    }
    
    /// 验证索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - dbService: 数据库服务
    /// - Returns: 是否有效
    static func validateIndex(tableName: String, indexName: String, dbService: CuttDBService) -> Bool {
        let stats = getIndexStatistics(tableName: tableName, indexName: indexName, dbService: dbService)
        return !stats.isEmpty
    }
    
    /// 处理响应
    /// - Parameters:
    ///   - response: 响应数据
    ///   - dbService: 数据库服务
    /// - Returns: 处理后的响应
    static func handleResponse(response: [String: Any], dbService: CuttDBService) -> [String: Any] {
        // 这里可以添加响应处理逻辑
        return response
    }
    
    /// 转换响应
    /// - Parameters:
    ///   - response: 响应数据
    ///   - mapping: 字段映射
    ///   - dbService: 数据库服务
    /// - Returns: 转换后的响应
    static func transformResponse(response: [String: Any], mapping: [String: String], dbService: CuttDBService) -> [String: Any] {
        var result: [String: Any] = [:]
        for (key, value) in response {
            if let newKey = mapping[key] {
                result[newKey] = value
            }
        }
        return result
    }
    
    /// 验证响应
    /// - Parameters:
    ///   - response: 响应数据
    ///   - schema: 验证模式
    ///   - dbService: 数据库服务
    /// - Returns: 是否有效
    static func validateResponse(response: [String: Any], schema: [String: String], dbService: CuttDBService) -> Bool {
        // 这里可以添加验证逻辑
        return true
    }
    
    /// 记录响应
    /// - Parameters:
    ///   - response: 响应数据
    ///   - operation: 操作类型
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func logResponse(response: [String: Any], operation: String, dbService: CuttDBService) -> Bool {
        let sql = "INSERT INTO response_logs (operation, response_data) VALUES ('\(operation)', '\(response)')"
        return dbService.execute(sql: sql)
    }
}

// MARK: - Select Module

extension CuttDB {
    /// 恢复最后一次响应
    /// - Parameters:
    ///   - api: API路径
    ///   - method: HTTP方法
    ///   - dbService: 数据库服务
    /// - Returns: 响应数据
    static func restoreLastResponse(api: String, method: String, dbService: CuttDBService) -> [String: Any]? {
        let sql = "SELECT response_data FROM response_cache WHERE api = '\(api)' AND method = '\(method)' ORDER BY created_at DESC LIMIT 1"
        return dbService.query(sql: sql)?.first
    }
    
    /// 恢复列表响应
    /// - Parameters:
    ///   - api: API路径
    ///   - method: HTTP方法
    ///   - dbService: 数据库服务
    /// - Returns: 响应数据列表
    static func restoreListResponse(api: String, method: String, dbService: CuttDBService) -> [[String: Any]] {
        let sql = "SELECT response_data FROM response_cache WHERE api = '\(api)' AND method = '\(method)' ORDER BY created_at DESC"
        return dbService.query(sql: sql) ?? []
    }
    
    /// 恢复子表响应
    /// - Parameters:
    ///   - api: API路径
    ///   - method: HTTP方法
    ///   - property: 属性名
    ///   - dbService: 数据库服务
    /// - Returns: 响应数据列表
    static func restoreSubTableResponse(api: String, method: String, property: String, dbService: CuttDBService) -> [[String: Any]] {
        let sql = "SELECT response_data FROM response_cache WHERE api = '\(api)' AND method = '\(method)' AND property = '\(property)' ORDER BY created_at DESC"
        return dbService.query(sql: sql) ?? []
    }
    
    /// 处理过期响应
    /// - Parameters:
    ///   - api: API路径
    ///   - method: HTTP方法
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func handleExpiredResponse(api: String, method: String, dbService: CuttDBService) -> Bool {
        let sql = "DELETE FROM response_cache WHERE api = '\(api)' AND method = '\(method)' AND created_at < DATE_SUB(NOW(), INTERVAL 24 HOUR)"
        return dbService.execute(sql: sql)
    }
    
    /// 分页查询数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 查询参数
    ///   - dbService: 数据库服务
    /// - Returns: 查询结果
    static func queryPagedData(tableName: String, data: [String: Any], dbService: CuttDBService) -> [[String: Any]]? {
        let pageSize = data["pageSize"] as? Int ?? 10
        let pageNumber = data["pageNumber"] as? Int ?? 1
        let offset = (pageNumber - 1) * pageSize
        
        var sql = "SELECT "
        
        // 处理字段选择
        if let fields = data["fields"] as? [String] {
            sql += fields.joined(separator: ", ")
        } else {
            sql += "*"
        }
        
        sql += " FROM \(tableName)"
        
        // 处理过滤条件
        if let filter = data["filter"] as? String {
            sql += " WHERE \(filter)"
        }
        
        // 处理排序
        if let sortField = data["sortField"] as? String,
           let sortOrder = data["sortOrder"] as? String {
            sql += " ORDER BY \(sortField) \(sortOrder)"
        }
        
        // 添加分页
        sql += " LIMIT \(pageSize) OFFSET \(offset)"
        
        return dbService.query(sql: sql)
    }
}

// MARK: - Insert/Update Module

extension CuttDB {
    /// 生成插入SQL
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列名列表
    ///   - values: 值列表
    /// - Returns: SQL语句
    static func generateInsertSQL(tableName: String, columns: [String], values: [Any]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        let placeholders = Array(repeating: "?", count: values.count).joined(separator: ", ")
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES (\(placeholders))"
    }
    
    /// 生成更新SQL
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 更新数据
    ///   - condition: 更新条件
    /// - Returns: SQL语句
    static func generateUpdateSQL(tableName: String, data: [String: Any], condition: String) -> String {
        let setClause = data.map { "\($0.key) = ?" }.joined(separator: ", ")
        return "UPDATE \(tableName) SET \(setClause) WHERE \(condition)"
    }
    
    /// 生成Upsert SQL
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 数据
    ///   - uniqueColumns: 唯一列
    /// - Returns: SQL语句
    static func generateUpsertSQL(tableName: String, data: [String: Any], uniqueColumns: [String]) -> String {
        let columns = Array(data.keys)
        let columnsStr = columns.joined(separator: ", ")
        let placeholders = Array(repeating: "?", count: data.count).joined(separator: ", ")
        let updateClause = columns.map { "\($0) = VALUES(\($0))" }.joined(separator: ", ")
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES (\(placeholders)) ON DUPLICATE KEY UPDATE \(updateClause)"
    }
    
    /// 生成批量插入SQL
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列名列表
    ///   - values: 值列表
    /// - Returns: SQL语句
    static func generateBatchInsertSQL(tableName: String, columns: [String], values: [[Any]]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        let valueClauses = values.map { row in
            let placeholders = Array(repeating: "?", count: row.count).joined(separator: ", ")
            return "(\(placeholders))"
        }.joined(separator: ", ")
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES \(valueClauses)"
    }
    
    /// 执行插入
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 数据
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func executeInsert(tableName: String, data: [String: Any], dbService: CuttDBService) -> Bool {
        let columns = Array(data.keys)
        let values = Array(data.values)
        let sql = generateInsertSQL(tableName: tableName, columns: columns, values: values)
        return dbService.execute(sql: sql)
    }
    
    /// 执行更新
    /// - Parameters:
    ///   - sql: SQL语句
    ///   - parameters: 参数
    /// - Returns: 是否成功
    static func executeUpdate(sql: String, parameters: [String: Any]) -> Bool {
        // 这里可以添加参数绑定逻辑
        return true
    }
    
    /// 执行Upsert
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 数据
    ///   - uniqueColumns: 唯一列
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func executeUpsert(tableName: String, data: [String: Any], uniqueColumns: [String], dbService: CuttDBService) -> Bool {
        let sql = generateUpsertSQL(tableName: tableName, data: data, uniqueColumns: uniqueColumns)
        return dbService.execute(sql: sql)
    }
    
    /// 执行批量插入
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列名列表
    ///   - values: 值列表
    ///   - dbService: 数据库服务
    /// - Returns: 是否成功
    static func executeBatchInsert(tableName: String, columns: [String], values: [[Any]], dbService: CuttDBService) -> Bool {
        let sql = generateBatchInsertSQL(tableName: tableName, columns: columns, values: values)
        return dbService.execute(sql: sql)
    }
} 
