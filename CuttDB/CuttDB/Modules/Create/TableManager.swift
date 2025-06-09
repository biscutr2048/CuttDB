import Foundation

/// 表管理器
internal struct TableManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 确保表存在
    func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        let sql = SQLGenerator.createTableIfNotExists(tableName: tableName, columns: columns)
        return service.executeSQL(sql)
    }
    
    /// 确保子表存在
    func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        let subTableName = "\(tableName)_\(property)"
        return ensureTableExists(tableName: subTableName, columns: columns)
    }
    
    /// 检查表是否存在
    func tableExists(_ tableName: String) -> Bool {
        let sql = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(tableName)'"
        let result = service.query(sql)
        return !result.isEmpty
    }
    
    /// 获取表结构
    func getTableStructure(_ tableName: String) -> [String: String] {
        service.getTableStructure(tableName)
    }
    
    /// 验证表定义
    func validateTableDefinition(tableName: String, expectedDefinition: [String: Any]) -> Bool {
        service.validateTableDefinition(tableName: tableName, expectedDefinition: expectedDefinition)
    }
} 