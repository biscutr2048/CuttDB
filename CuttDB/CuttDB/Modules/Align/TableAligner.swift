import Foundation

/// 表对齐器 - 负责表结构的对齐和迁移
internal struct TableAligner {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 对齐表结构
    /// - Parameters:
    ///   - tableName: 表名
    ///   - expectedColumns: 期望的列定义
    /// - Returns: 是否对齐成功
    func alignTable(tableName: String, expectedColumns: [String: String]) -> Bool {
        // 获取当前表结构
        let currentColumns = getCurrentColumns(tableName: tableName)
        
        // 添加缺失的列
        for (columnName, columnType) in expectedColumns {
            if !currentColumns.contains(where: { $0.name == columnName }) {
                let sql = "ALTER TABLE \(tableName) ADD COLUMN \(columnName) \(columnType)"
                if !service.execute(sql: sql, parameters: nil) > 0 {
                    return false
                }
            }
        }
        
        return true
    }
    
    /// 获取当前表的列定义
    private func getCurrentColumns(tableName: String) -> [(name: String, type: String)] {
        let sql = "PRAGMA table_info(\(tableName))"
        let result = service.query(sql: sql, parameters: nil)
        
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
            return service.executeSQL(sql)
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
        let results = service.query(sql)
        
        return results.compactMap { row in
            row[idColumn] as? String
        }
    }
} 