import Foundation

/// 列表查询管理器 - 负责列表数据的查询操作
public struct ListQuery {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 查询列表数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    ///   - orderBy: 排序字段
    ///   - columns: 要查询的列
    /// - Returns: 查询结果列表
    public func queryList(tableName: String, whereClause: String? = nil, orderBy: String? = nil, columns: [String] = ["*"]) -> [[String: Any]] {
        let sql = generateSelectSQL(tableName: tableName, whereClause: whereClause, orderBy: orderBy, columns: columns)
        return service.query(sql: sql, parameters: nil)
    }
    
    /// 查询子表列表
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - parentId: 父表ID
    /// - Returns: 子表数据列表
    public func querySubTableList(parentTable: String, subTable: String, parentId: String) -> [[String: Any]] {
        let whereClause = "\(parentTable)_id = '\(parentId)'"
        return queryList(tableName: subTable, whereClause: whereClause)
    }
    
    /// 生成查询SQL
    private func generateSelectSQL(tableName: String, whereClause: String?, orderBy: String?, columns: [String]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        var sql = "SELECT \(columnsStr) FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        if let orderBy = orderBy {
            sql += " ORDER BY \(orderBy)"
        }
        
        return sql
    }
} 