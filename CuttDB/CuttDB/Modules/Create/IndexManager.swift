import Foundation

/// 索引管理器 - 负责索引的创建和管理
internal struct IndexManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 创建索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - columns: 索引列
    /// - Returns: 是否创建成功
    func createIndex(tableName: String, indexName: String, columns: [String]) -> Bool {
        let sql = generateCreateIndexSQL(tableName: tableName, indexName: indexName, columns: columns)
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 检查索引是否存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    /// - Returns: 是否存在
    func indexExists(tableName: String, indexName: String) -> Bool {
        let sql = "SELECT name FROM sqlite_master WHERE type='index' AND tbl_name='\(tableName)' AND name='\(indexName)'"
        let result = service.query(sql: sql, parameters: nil)
        return !result.isEmpty
    }
    
    /// 为列表属性创建索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - listProperty: 列表属性名
    /// - Returns: 是否创建成功
    public func createListPropertyIndex(tableName: String, listProperty: String) -> Bool {
        let indexName = "idx_\(tableName)_\(listProperty)"
        let columns = ["\(listProperty)_id"]
        return createIndex(tableName: tableName, indexName: indexName, columns: columns)
    }
    
    /// 生成创建索引SQL
    private func generateCreateIndexSQL(tableName: String, indexName: String, columns: [String]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        return "CREATE INDEX IF NOT EXISTS \(indexName) ON \(tableName) (\(columnsStr))"
    }
} 