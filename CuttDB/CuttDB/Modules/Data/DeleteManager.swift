import Foundation

/// 删除管理器 - 负责数据删除操作
public struct DeleteManager {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 删除数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 删除条件
    /// - Returns: 是否删除成功
    public func delete(tableName: String, whereClause: String) -> Bool {
        let sql = generateDeleteSQL(tableName: tableName, whereClause: whereClause)
        return service.executeSQL(sql)
    }
    
    /// 根据ID删除数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 对象ID
    /// - Returns: 是否删除成功
    public func deleteById(tableName: String, id: String) -> Bool {
        return delete(tableName: tableName, whereClause: "id = '\(id)'")
    }
    
    /// 删除子表数据
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - parentId: 父表ID
    ///   - whereClause: 删除条件
    /// - Returns: 是否删除成功
    public func deleteSubTable(parentTable: String, subTable: String, parentId: String, whereClause: String? = nil) -> Bool {
        var fullWhereClause = "\(parentTable)_id = '\(parentId)'"
        if let whereClause = whereClause {
            fullWhereClause += " AND \(whereClause)"
        }
        return delete(tableName: subTable, whereClause: fullWhereClause)
    }
    
    /// 标记数据为已删除
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 删除条件
    /// - Returns: 是否标记成功
    public func markAsDeleted(tableName: String, whereClause: String) -> Bool {
        let values = ["is_deleted": 1, "deleted_at": Date().timeIntervalSince1970]
        let sql = generateUpdateSQL(tableName: tableName, values: values, whereClause: whereClause)
        return service.executeSQL(sql)
    }
    
    /// 生成删除SQL
    private func generateDeleteSQL(tableName: String, whereClause: String) -> String {
        return "DELETE FROM \(tableName) WHERE \(whereClause)"
    }
    
    /// 生成更新SQL
    private func generateUpdateSQL(tableName: String, values: [String: Any], whereClause: String) -> String {
        let setClause = values.map { (key, value) in
            let escapedKey = StringUtils.escapeSQLString(key)
            if let stringValue = value as? String {
                return "\(escapedKey) = '\(StringUtils.escapeSQLString(stringValue))'"
            } else {
                return "\(escapedKey) = \(value)"
            }
        }.joined(separator: ", ")
        
        return "UPDATE \(tableName) SET \(setClause) WHERE \(whereClause)"
    }
} 