import Foundation

/// 表定义管理模块
struct TableDefinitionManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 从 JSON 结构提取表格定义
    /// - Parameter json: 任意 JSON 对象（通常为 [String: Any]）
    /// - Returns: [(字段名, 字段类型)]，嵌套结构类型为 TEXT，内容为 json 字符串
    func extractTableDefinition(from json: Any) -> [(name: String, type: String)] {
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
    
    /// 创建表定义
    /// - Parameters:
    ///   - tableName: 表名
    ///   - definition: 表定义
    /// - Returns: 是否成功
    func createTableDefinition(tableName: String, definition: [String: Any]) -> Bool {
        let columns = extractTableDefinition(from: definition)
        let columnDefinitions = columns.map { "\($0.name) \($0.type)" }
        return service.execute(sql: SQLGenerator.generateCreateTableSQL(tableName: tableName, columns: columnDefinitions))
    }
    
    /// 验证表结构
    /// - Parameters:
    ///   - tableName: 表名
    ///   - expectedColumns: 期望的列定义
    /// - Returns: 是否验证通过
    func validateTableStructure(tableName: String, expectedColumns: [String: String]) -> Bool {
        let currentStructure = service.getTableStructure(tableName)
        for (column, type) in expectedColumns {
            guard let currentType = currentStructure[column] else { return false }
            if currentType != type {
                return false
            }
        }
        return true
    }
    
    /// 创建索引（如果需要）
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexes: 索引定义
    /// - Returns: 是否成功
    func createIndexesIfNeeded(tableName: String, indexes: [String: String]) -> Bool {
        for (indexName, columns) in indexes {
            let columnList = columns.components(separatedBy: ",")
            if !createIndexIfNeeded(tableName: tableName, indexName: indexName, columns: columnList) {
                return false
            }
        }
        return true
    }
    
    /// 创建单个索引（如果需要）
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - columns: 索引列
    /// - Returns: 是否成功
    func createIndexIfNeeded(tableName: String, indexName: String, columns: [String]) -> Bool {
        if !service.indexExists(tableName: tableName, indexName: indexName) {
            return service.createIndex(tableName: tableName, indexName: indexName, columns: columns)
        }
        return true
    }
    
    /// 创建子表
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - columns: 列定义
    /// - Returns: 是否成功
    func createSubTable(parentTable: String, subTable: String, columns: [String: String]) -> Bool {
        let columnDefinitions = columns.map { "\($0.key) \($0.value)" }
        let sql = SQLGenerator.generateCreateTableSQL(tableName: subTable, columns: columnDefinitions)
        return service.execute(sql: sql)
    }
    
    /// 验证子表结构
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - expectedColumns: 期望的列定义
    /// - Returns: 是否验证通过
    func validateSubTableStructure(parentTable: String, subTable: String, expectedColumns: [String: String]) -> Bool {
        return validateTableStructure(tableName: subTable, expectedColumns: expectedColumns)
    }
} 