import Foundation

/// 数据对齐器 - 负责数据对齐操作
internal struct DataAligner {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 对齐数据
    /// - Parameters:
    ///   - sourceTable: 源表名
    ///   - targetTable: 目标表名
    ///   - columns: 列定义
    /// - Returns: 是否对齐成功
    func alignData(sourceTable: String, targetTable: String, columns: [String: String]) -> Bool {
        // 获取源表数据
        let sourceData = getTableData(sourceTable)
        
        // 清理目标表中的重复数据
        if !cleanupDuplicates(targetTable, uniqueColumns: Array(columns.keys)) {
            return false
        }
        
        // 插入数据到目标表
        for row in sourceData {
            let sql = generateInsertSQL(tableName: targetTable, values: row)
            if service.execute(sql: sql, parameters: nil) <= 0 {
                return false
            }
        }
        
        return true
    }
    
    /// 获取表数据
    private func getTableData(_ tableName: String) -> [[String: Any]] {
        let sql = "SELECT * FROM \(tableName)"
        return service.query(sql: sql, parameters: nil)
    }
    
    /// 清理重复数据
    private func cleanupDuplicates(_ tableName: String, uniqueColumns: [String]) -> Bool {
        let columnsStr = uniqueColumns.joined(separator: ", ")
        let sql = """
            DELETE FROM \(tableName)
            WHERE rowid NOT IN (
                SELECT MIN(rowid)
                FROM \(tableName)
                GROUP BY \(columnsStr)
            )
        """
        return service.execute(sql: sql, parameters: nil) >= 0
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
} 