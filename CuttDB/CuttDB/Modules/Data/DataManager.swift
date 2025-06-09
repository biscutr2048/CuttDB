//
//  DataManager.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 数据管理器 - 负责数据操作
internal struct DataManager {
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
        
        let sql = "INSERT INTO \(tableName) (\(columns)) VALUES (\(valueStrings))"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 根据ID更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 对象ID
    ///   - values: 更新的值
    /// - Returns: 是否更新成功
    func updateById(tableName: String, id: String, values: [String: Any]) -> Bool {
        let setClause = values.map { (key, value) in
            let escapedKey = StringUtils.escapeSQLString(key)
            if let stringValue = value as? String {
                return "\(escapedKey) = '\(StringUtils.escapeSQLString(stringValue))'"
            } else {
                return "\(escapedKey) = \(value)"
            }
        }.joined(separator: ", ")
        
        let sql = "UPDATE \(tableName) SET \(setClause) WHERE id = '\(id)'"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 根据ID删除数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 对象ID
    /// - Returns: 是否删除成功
    func deleteById(tableName: String, id: String) -> Bool {
        let sql = "DELETE FROM \(tableName) WHERE id = '\(id)'"
        return service.execute(sql: sql, parameters: nil) > 0
    }
} 