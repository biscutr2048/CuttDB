import Foundation

/// 表对齐器 - 负责表结构对齐
internal struct TableAligner {
    private let service: CuttDBService
    private let tableManager: TableManager
    
    init(service: CuttDBService) {
        self.service = service
        self.tableManager = TableManager(service: service)
    }
    
    /// 对齐表结构
    /// - Parameters:
    ///   - sourceTable: 源表名
    ///   - targetTable: 目标表名
    ///   - columns: 列定义
    /// - Returns: 是否对齐成功
    func alignTable(sourceTable: String, targetTable: String, columns: [String: String]) -> Bool {
        // 检查源表是否存在
        guard tableManager.tableExists(tableName: sourceTable) else {
            return false
        }
        
        // 确保目标表存在
        if !tableManager.tableExists(tableName: targetTable) {
            if !tableManager.createTable(tableName: targetTable, columns: columns) {
                return false
            }
        }
        
        // 验证目标表结构
        if !tableManager.validateTableDefinition(tableName: targetTable, expectedDefinition: columns) {
            return false
        }
        
        // 对齐数据
        return alignData(sourceTable: sourceTable, targetTable: targetTable, columns: columns)
    }
    
    /// 对齐数据
    private func alignData(sourceTable: String, targetTable: String, columns: [String: String]) -> Bool {
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
        return service.query(sql: sql, parameters: [])
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
    
    /// 获取当前表的列定义
    private func getCurrentColumns(tableName: String) -> [(name: String, type: String)] {
        let sql = "PRAGMA table_info(\(tableName))"
        let result = service.query(sql: sql, parameters: [])
        
        return result.map { row in
            let name = row["name"] as? String ?? ""
            let type = row["type"] as? String ?? ""
            return (name: name, type: type)
        }
    }
    
    /// 创建新表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列定义
    /// - Returns: 是否创建成功
    func createTable(tableName: String, columns: [String: String]) -> Bool {
        let columnDefinitions = columns.map { "\($0.key) \($0.value)" }.joined(separator: ", ")
        let sql = "CREATE TABLE IF NOT EXISTS \(tableName) (\(columnDefinitions))"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 删除缺失的数据
    /// - Parameters:
    ///   - sourceTable: 源表名
    ///   - targetTable: 目标表名
    ///   - idColumn: ID列名
    /// - Returns: 是否删除成功
    public func dropMissingData(sourceTable: String, targetTable: String, idColumn: String = "id") -> Bool {
        // 获取源表的所有ID
        let sourceIds = getTableIds(tableName: sourceTable, idColumn: idColumn)
        
        // 获取目标表的所有ID
        let targetIds = getTableIds(tableName: targetTable, idColumn: idColumn)
        
        // 找出需要删除的ID
        let idsToDelete = targetIds.filter { !sourceIds.contains($0) }
        
        // 删除缺失的数据
        if !idsToDelete.isEmpty {
            let idList = idsToDelete.map { "'\(StringUtils.escapeSQLString($0))'" }.joined(separator: ", ")
            let sql = "DELETE FROM \(targetTable) WHERE \(idColumn) IN (\(idList))"
            return service.execute(sql: sql, parameters: nil) > 0
        }
        
        return true
    }
    
    /// 获取表的所有ID
    /// - Parameters:
    ///   - tableName: 表名
    ///   - idColumn: ID列名
    /// - Returns: ID数组
    private func getTableIds(tableName: String, idColumn: String) -> [String] {
        let sql = "SELECT \(idColumn) FROM \(tableName)"
        let results = service.query(sql: sql, parameters: [])
        
        return results.compactMap { row in
            row[idColumn] as? String
        }
    }
} 