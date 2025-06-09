//
//  BatchManager.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 批处理管理器 - 负责批量数据操作
internal struct BatchManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
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
    
    /// 批量更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - values: 更新的值数组
    ///   - idColumn: ID列名
    /// - Returns: 是否更新成功
    func batchUpdate(tableName: String, values: [[String: Any]], idColumn: String = "id") -> Bool {
        var success = true
        for row in values {
            if let id = row[idColumn] as? String {
                let updateValues = row.filter { $0.key != idColumn }
                let whereClause = "\(idColumn) = '\(id)'"
                let sql = generateUpdateSQL(tableName: tableName, values: updateValues, whereClause: whereClause)
                success = success && service.execute(sql: sql, parameters: nil) > 0
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
    func batchDelete(tableName: String, ids: [String], idColumn: String = "id") -> Bool {
        let idList = ids.map { "'\($0)'" }.joined(separator: ", ")
        let sql = "DELETE FROM \(tableName) WHERE \(idColumn) IN (\(idList))"
        return service.execute(sql: sql, parameters: nil) > 0
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