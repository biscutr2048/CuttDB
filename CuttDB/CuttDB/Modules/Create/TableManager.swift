import Foundation

/// 表管理器 - 负责表的创建和管理
internal struct TableManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 创建表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列定义
    /// - Returns: 是否创建成功
    func createTable(tableName: String, columns: [String: String]) -> Bool {
        let columnDefinitions = columns.map { "\($0.key) \($0.value)" }.joined(separator: ", ")
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName) (\(columnDefinitions))"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 检查表是否存在
    /// - Parameter tableName: 表名
    /// - Returns: 是否存在
    func tableExists(tableName: String) -> Bool {
        let sql = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(tableName)'"
        let result = service.query(sql: sql, parameters: nil)
        return !result.isEmpty
    }
    
    /// 删除表
    /// - Parameter tableName: 表名
    /// - Returns: 是否删除成功
    func dropTable(tableName: String) -> Bool {
        let sql = "DROP TABLE IF EXISTS \(tableName)"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 确保表存在
    func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        let columnDefinitions = columns.map { "\($0) TEXT" }.joined(separator: ", ")
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName) (\(columnDefinitions))"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 确保子表存在
    func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        let subTableName = "\(tableName)_\(property)"
        return ensureTableExists(tableName: subTableName, columns: columns)
    }
    
    /// 获取表结构
    func getTableStructure(_ tableName: String) -> [String: String] {
        let sql = "PRAGMA table_info(\(tableName))"
        let result = service.query(sql: sql, parameters: nil)
        
        var structure: [String: String] = [:]
        for row in result {
            if let name = row["name"] as? String,
               let type = row["type"] as? String {
                structure[name] = type
            }
        }
        return structure
    }
    
    /// 验证表定义
    func validateTableDefinition(tableName: String, expectedDefinition: [String: Any]) -> Bool {
        let currentStructure = getTableStructure(tableName)
        
        for (columnName, columnType) in expectedDefinition {
            guard let type = columnType as? String else { continue }
            guard let currentType = currentStructure[columnName] else { return false }
            
            if currentType.uppercased() != type.uppercased() {
                return false
            }
        }
        
        return true
    }
} 