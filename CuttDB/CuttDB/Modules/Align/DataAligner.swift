import Foundation

/// 数据对齐管理器 - 负责数据对齐操作
public struct DataAligner {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 同步数据
    /// - Parameters:
    ///   - sourceTable: 源表名
    ///   - targetTable: 目标表名
    ///   - idColumn: ID列名
    /// - Returns: 是否同步成功
    public func syncData(sourceTable: String, targetTable: String, idColumn: String = "id") -> Bool {
        // 获取源表数据
        let sourceData = getTableData(tableName: sourceTable)
        
        // 获取目标表数据
        let targetData = getTableData(tableName: targetTable)
        
        // 找出需要更新的数据
        let dataToUpdate = sourceData.filter { sourceRow in
            if let sourceId = sourceRow[idColumn] as? String {
                return targetData.contains { targetRow in
                    targetRow[idColumn] as? String == sourceId
                }
            }
            return false
        }
        
        // 找出需要插入的数据
        let dataToInsert = sourceData.filter { sourceRow in
            if let sourceId = sourceRow[idColumn] as? String {
                return !targetData.contains { targetRow in
                    targetRow[idColumn] as? String == sourceId
                }
            }
            return false
        }
        
        // 更新数据
        for row in dataToUpdate {
            if let id = row[idColumn] as? String {
                let whereClause = "\(idColumn) = '\(id)'"
                let updateValues = row.filter { $0.key != idColumn }
                let sql = generateUpdateSQL(tableName: targetTable, values: updateValues, whereClause: whereClause)
                if !service.executeSQL(sql) {
                    return false
                }
            }
        }
        
        // 插入数据
        if !dataToInsert.isEmpty {
            let columns = Array(dataToInsert[0].keys)
            let values = dataToInsert.map { row in
                columns.map { column in
                    row[column] ?? NSNull()
                }
            }
            let sql = generateBatchInsertSQL(tableName: targetTable, columns: columns, values: values)
            if !service.executeSQL(sql) {
                return false
            }
        }
        
        return true
    }
    
    /// 获取表的所有数据
    /// - Parameter tableName: 表名
    /// - Returns: 数据数组
    private func getTableData(tableName: String) -> [[String: Any]] {
        let sql = "SELECT * FROM \(tableName)"
        return service.query(sql)
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
    
    /// 生成批量插入SQL
    private func generateBatchInsertSQL(tableName: String, columns: [String], values: [[Any]]) -> String {
        let columnsStr = columns.map { StringUtils.escapeSQLString($0) }.joined(separator: ", ")
        let valuesStr = values.map { row in
            let rowValues = row.map { value in
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