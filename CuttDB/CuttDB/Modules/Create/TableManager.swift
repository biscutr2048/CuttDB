import Foundation

/// 表管理模块
struct TableManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 确保表存在
    func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        if !service.tableExists(tableName) {
            let sql = SQLGenerator.generateCreateTableSQL(tableName: tableName, columns: columns)
            return service.execute(sql: sql)
        }
        return true
    }
    
    /// 确保子表存在
    func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        let subTableName = "\(tableName)-sub-\(property)"
        return ensureTableExists(tableName: subTableName, columns: columns)
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