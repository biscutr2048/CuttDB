//
//  TableDefinitionManager.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 表定义管理器 - 负责表定义的管理
internal struct TableDefinitionManager {
    private let service: CuttDBService
    private let indexManager: IndexManager
    
    init(service: CuttDBService) {
        self.service = service
        self.indexManager = IndexManager(service: service)
    }
    
    /// 创建表定义
    /// - Parameters:
    ///   - tableName: 表名
    ///   - definition: 表定义
    /// - Returns: 是否创建成功
    func createTableDefinition(tableName: String, definition: [String: Any]) -> Bool {
        let sql = generateCreateTableSQL(tableName: tableName, definition: definition)
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 验证表结构
    /// - Parameters:
    ///   - tableName: 表名
    ///   - expectedColumns: 期望的列定义
    /// - Returns: 是否验证通过
    func validateTableStructure(tableName: String, expectedColumns: [String: String]) -> Bool {
        let currentColumns = getCurrentColumns(tableName: tableName)
        
        // 检查所有期望的列是否存在且类型匹配
        for (columnName, columnType) in expectedColumns {
            guard let currentColumn = currentColumns.first(where: { $0.name == columnName }) else {
                return false
            }
            
            if currentColumn.type.uppercased() != columnType.uppercased() {
                return false
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
    
    /// 生成创建表SQL
    private func generateCreateTableSQL(tableName: String, definition: [String: Any]) -> String {
        let columns = definition.map { (key, value) in
            if let type = value as? String {
                return "\(key) \(type)"
            } else {
                return "\(key) TEXT"
            }
        }.joined(separator: ", ")
        
        return "CREATE TABLE IF NOT EXISTS \(tableName) (\(columns))"
    }
    
    /// 创建索引
    func createIndexesIfNeeded(tableName: String, indexes: [String: String]) -> Bool {
        for (indexName, columns) in indexes {
            if !createIndexIfNeeded(tableName: tableName, indexName: indexName, columns: columns.components(separatedBy: ",")) {
                return false
            }
        }
        return true
    }
    
    /// 创建单个索引
    private func createIndexIfNeeded(tableName: String, indexName: String, columns: [String]) -> Bool {
        return indexManager.createIndex(tableName: tableName, indexName: indexName, columns: columns)
    }
    
    /// 从JSON提取表定义
    private func extractTableDefinition(from json: Any) -> [(name: String, type: String)]? {
        guard let dict = json as? [String: Any] else { return nil }
        
        return dict.compactMap { key, value -> (name: String, type: String)? in
            let type: String
            switch value {
            case is Int: type = "INTEGER"
            case is Double: type = "REAL"
            case is String: type = "TEXT"
            case is Bool: type = "INTEGER"
            case is [Any]: type = "TEXT"
            case is [String: Any]: type = "TEXT"
            default: return nil
            }
            return (name: key, type: type)
        }
    }
    
    /// 创建子表
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - columns: 列定义
    /// - Returns: 是否成功
    func createSubTable(parentTable: String, subTable: String, columns: [String: String]) -> Bool {
        let columnDefinitions = columns.map { "\($0.key) \($0.value)" }.joined(separator: ", ")
        let sql = "CREATE TABLE IF NOT EXISTS \(subTable) (\(columnDefinitions))"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 验证子表结构
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - expectedColumns: 期望的列定义
    /// - Returns: 是否验证通过
    func validateSubTableStructure(parentTable: String, subTable: String, expectedColumns: [String: String]) -> Bool {
        return validateTableStructure(tableName: subTable, expectedColumns: expectedColumns)
    }
} 