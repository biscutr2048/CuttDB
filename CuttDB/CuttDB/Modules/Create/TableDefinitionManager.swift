import Foundation

/// 表定义管理器
internal struct TableDefinitionManager {
    private let service: CuttDBService
    private let indexManager: IndexManager
    
    init(service: CuttDBService) {
        self.service = service
        self.indexManager = IndexManager(service: service)
    }
    
    /// 从JSON创建表定义
    func createTableDefinition(tableName: String, definition: Any) -> Bool {
        guard let columns = extractTableDefinition(from: definition) else {
            return false
        }
        
        let sql = SQLGenerator.createTableIfNotExists(tableName: tableName, columns: columns)
        return service.executeSQL(sql)
    }
    
    /// 验证表结构
    func validateTableStructure(tableName: String, expectedColumns: [String: String]) -> Bool {
        let sql = "PRAGMA table_info(\(tableName))"
        let result = service.query(sql)
        
        guard !result.isEmpty else { return false }
        
        let existingColumns = Dictionary(uniqueKeysWithValues: result.compactMap { row -> (String, String)? in
            guard let name = row["name"] as? String,
                  let type = row["type"] as? String else {
                return nil
            }
            return (name, type)
        })
        
        for (name, type) in expectedColumns {
            guard let existingType = existingColumns[name],
                  existingType.lowercased() == type.lowercased() else {
                return false
            }
        }
        
        return true
    }
    
    /// 创建索引
    func createIndexesIfNeeded(tableName: String, indexes: [String: String]) -> Bool {
        for (indexName, columns) in indexes {
            if !createIndexIfNeeded(tableName: tableName, indexName: indexName, columns: columns.components(separatedBy: ",")) {
                return false
            }
        }
        return true
    }
    
    /// 创建单个索引
    private func createIndexIfNeeded(tableName: String, indexName: String, columns: [String]) -> Bool {
        return indexManager.createIndexIfNeeded(tableName: tableName, indexName: indexName, columns: columns)
    }
    
    /// 从JSON提取表定义
    private func extractTableDefinition(from json: Any) -> [(name: String, type: String)]? {
        guard let dict = json as? [String: Any] else { return nil }
        
        return dict.compactMap { key, value -> (name: String, type: String)? in
            let type: String
            switch value {
            case is Int: type = "INTEGER"
            case is Double: type = "REAL"
            case is String: type = "TEXT"
            case is Bool: type = "INTEGER"
            case is [Any]: type = "TEXT"
            case is [String: Any]: type = "TEXT"
            default: return nil
            }
            return (name: key, type: type)
        }
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