import Foundation

/// 对象查询管理器 - 负责单个对象的查询操作
public struct ObjectQuery {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 查询单个对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    ///   - columns: 要查询的列
    /// - Returns: 查询结果
    public func queryObject(tableName: String, whereClause: String, columns: [String] = ["*"]) -> [String: Any]? {
        let sql = generateSelectSQL(tableName: tableName, whereClause: whereClause, columns: columns)
        let results = service.query(sql)
        return results.first
    }
    
    /// 根据ID查询对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 对象ID
    /// - Returns: 查询结果
    public func queryObjectById(tableName: String, id: String) -> [String: Any]? {
        return queryObject(tableName: tableName, whereClause: "id = '\(id)'")
    }
    
    /// 生成查询SQL
    private func generateSelectSQL(tableName: String, whereClause: String, columns: [String]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        return "SELECT \(columnsStr) FROM \(tableName) WHERE \(whereClause) LIMIT 1"
    }
} 