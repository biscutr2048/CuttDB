import Foundation

/// 插入管理器 - 负责数据插入操作
internal struct InsertManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 插入数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - values: 插入的值
    /// - Returns: 是否插入成功
    func insert(tableName: String, values: [String: Any]) -> Bool {
        let sql = generateInsertSQL(tableName: tableName, values: values)
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 批量插入数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - values: 插入的值数组
    /// - Returns: 是否插入成功
    func batchInsert(tableName: String, values: [[String: Any]]) -> Bool {
        guard !values.isEmpty else { return true }
        
        let columns = Array(values[0].keys)
        let sql = generateBatchInsertSQL(tableName: tableName, columns: columns, values: values)
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 生成插入SQL
    private func generateInsertSQL(tableName: String, values: [String: Any]) -> String {
        let columns = values.keys.map { StringUtils.escapeSQLString($0) }.joined(separator: ", ")
        let valueStrings = values.values.map { value in
            if let stringValue = value as? String {
                return "'\(StringUtils.escapeSQLString(stringValue))'"
            } else if value is NSNull {
                return "NULL"
            } else {
                return "\(value)"
            }
        }.joined(separator: ", ")
        
        return "INSERT INTO \(tableName) (\(columns)) VALUES (\(valueStrings))"
    }
    
    /// 生成批量插入SQL
    private func generateBatchInsertSQL(tableName: String, columns: [String], values: [[String: Any]]) -> String {
        let columnsStr = columns.map { StringUtils.escapeSQLString($0) }.joined(separator: ", ")
        let valuesStr = values.map { row in
            let rowValues = columns.map { column in
                let value = row[column] ?? NSNull()
                if let stringValue = value as? String {
                    return "'\(StringUtils.escapeSQLString(stringValue))'"
                } else if value is NSNull {
                    return "NULL"
                } else {
                    return "\(value)"
                }
            }
            return "(\(rowValues.joined(separator: ", ")))"
        }.joined(separator: ", ")
        
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES \(valuesStr)"
    }
} 