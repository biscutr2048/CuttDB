import Foundation

/// 批量操作管理器 - 负责批量数据处理操作
public struct BatchManager {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 批量插入数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列名数组
    ///   - values: 值数组
    /// - Returns: 是否插入成功
    public func batchInsert(tableName: String, columns: [String], values: [[Any]]) -> Bool {
        let sql = generateBatchInsertSQL(tableName: tableName, columns: columns, values: values)
        return service.executeSQL(sql)
    }
    
    /// 批量更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - values: 要更新的值数组
    ///   - idColumn: ID列名
    /// - Returns: 是否更新成功
    public func batchUpdate(tableName: String, values: [[String: Any]], idColumn: String = "id") -> Bool {
        var success = true
        for value in values {
            if let id = value[idColumn] as? String {
                let whereClause = "\(idColumn) = '\(id)'"
                let updateValues = value.filter { $0.key != idColumn }
                let sql = generateUpdateSQL(tableName: tableName, values: updateValues, whereClause: whereClause)
                success = success && service.executeSQL(sql)
            }
        }
        return success
    }
    
    /// 批量删除数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - ids: ID数组
    ///   - idColumn: ID列名
    /// - Returns: 是否删除成功
    public func batchDelete(tableName: String, ids: [String], idColumn: String = "id") -> Bool {
        let idList = ids.map { "'\(StringUtils.escapeSQLString($0))'" }.joined(separator: ", ")
        let whereClause = "\(idColumn) IN (\(idList))"
        let sql = generateDeleteSQL(tableName: tableName, whereClause: whereClause)
        return service.executeSQL(sql)
    }
    
    /// 生成批量插入SQL
    private func generateBatchInsertSQL(tableName: String, columns: [String], values: [[Any]]) -> String {
        let columnsStr = columns.map { StringUtils.escapeSQLString($0) }.joined(separator: ", ")
        let valuesStr = values.map { row in
            let rowValues = row.map { value in
                if let stringValue = value as? String {
                    return "'\(StringUtils.escapeSQLString(stringValue))'"
                } else {
                    return "\(value)"
                }
            }
            return "(\(rowValues.joined(separator: ", ")))"
        }.joined(separator: ", ")
        
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES \(valuesStr)"
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
    
    /// 生成删除SQL
    private func generateDeleteSQL(tableName: String, whereClause: String) -> String {
        return "DELETE FROM \(tableName) WHERE \(whereClause)"
    }
} 