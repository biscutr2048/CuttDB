import Foundation

/// 表对齐管理器 - 负责表结构对齐操作
public struct TableAligner {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 升级目标表结构
    /// - Parameters:
    ///   - sourceTable: 源表名
    ///   - targetTable: 目标表名
    /// - Returns: 是否升级成功
    public func upgradeTableStructure(sourceTable: String, targetTable: String) -> Bool {
        // 获取源表结构
        guard let sourceColumns = getTableColumns(tableName: sourceTable) else {
            return false
        }
        
        // 获取目标表结构
        guard let targetColumns = getTableColumns(tableName: targetTable) else {
            return false
        }
        
        // 找出需要添加的列
        let columnsToAdd = sourceColumns.filter { !targetColumns.contains($0) }
        
        // 添加缺失的列
        for column in columnsToAdd {
            let sql = "ALTER TABLE \(targetTable) ADD COLUMN \(column) TEXT"
            if !service.executeSQL(sql) {
                return false
            }
        }
        
        return true
    }
    
    /// 获取表的所有列
    /// - Parameter tableName: 表名
    /// - Returns: 列名数组
    private func getTableColumns(tableName: String) -> [String]? {
        let sql = "PRAGMA table_info(\(tableName))"
        let results = service.query(sql)
        
        return results.compactMap { row in
            row["name"] as? String
        }
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