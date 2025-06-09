import Foundation

/// 索引管理器 - 负责创建和管理数据库索引
public struct IndexManager {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 创建索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - columns: 索引列
    /// - Returns: 是否创建成功
    public func createIndex(tableName: String, indexName: String, columns: [String]) -> Bool {
        let sql = generateCreateIndexSQL(tableName: tableName, indexName: indexName, columns: columns)
        return service.executeSQL(sql)
    }
    
    /// 检查索引是否存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    /// - Returns: 索引是否存在
    public func indexExists(tableName: String, indexName: String) -> Bool {
        return service.indexExists(tableName: tableName, indexName: indexName)
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
    
    /// 生成创建索引的SQL语句
    private func generateCreateIndexSQL(tableName: String, indexName: String, columns: [String]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        return "CREATE INDEX IF NOT EXISTS \(indexName) ON \(tableName) (\(columnsStr))"
    }
} 