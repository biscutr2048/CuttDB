import Foundation

/// 分页查询管理器 - 负责分页查询操作
public struct PagedQuery {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 分页查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - page: 页码（从1开始）
    ///   - pageSize: 每页大小
    ///   - whereClause: 查询条件
    ///   - orderBy: 排序字段
    ///   - columns: 要查询的列
    /// - Returns: 分页查询结果
    public func queryPaged(tableName: String, page: Int, pageSize: Int, whereClause: String? = nil, orderBy: String? = nil, columns: [String] = ["*"]) -> (data: [[String: Any]], total: Int) {
        let offset = (page - 1) * pageSize
        let sql = generatePagedSQL(tableName: tableName, offset: offset, limit: pageSize, whereClause: whereClause, orderBy: orderBy, columns: columns)
        let countSQL = generateCountSQL(tableName: tableName, whereClause: whereClause)
        
        let data = service.query(sql)
        let total = service.query(countSQL).first?["count"] as? Int ?? 0
        
        return (data, total)
    }
    
    /// 生成分页查询SQL
    private func generatePagedSQL(tableName: String, offset: Int, limit: Int, whereClause: String?, orderBy: String?, columns: [String]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        var sql = "SELECT \(columnsStr) FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        if let orderBy = orderBy {
            sql += " ORDER BY \(orderBy)"
        }
        
        sql += " LIMIT \(limit) OFFSET \(offset)"
        return sql
    }
    
    /// 生成计数SQL
    private func generateCountSQL(tableName: String, whereClause: String?) -> String {
        var sql = "SELECT COUNT(*) as count FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        return sql
    }
} 