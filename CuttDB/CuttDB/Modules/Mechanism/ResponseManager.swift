//
//  ResponseManager.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 响应管理器 - 负责响应数据的管理
internal struct ResponseManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 保存响应数据
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    ///   - data: 响应数据
    ///   - expiration: 过期时间（秒）
    public func saveResponse(api: String, method: String, data: [String: Any], expiration: TimeInterval = 3600) {
        let key = generateRequestIndexKey(api: api, method: method)
        let sql = generateInsertSQL(tableName: "responses", values: [
            "key": key,
            "data": try? JSONSerialization.data(withJSONObject: data),
            "expiration": Date().timeIntervalSince1970 + expiration
        ])
        _ = service.execute(sql: sql, parameters: nil)
    }
    
    /// 获取响应数据
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    /// - Returns: 响应数据
    public func getResponse(api: String, method: String) -> [String: Any]? {
        let key = generateRequestIndexKey(api: api, method: method)
        let sql = "SELECT data FROM responses WHERE key = '\(key)' AND expiration > \(Date().timeIntervalSince1970)"
        let result = service.query(sql: sql, parameters: nil)
        
        guard let first = result.first,
              let data = first["data"] as? Data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json
    }
    
    /// 删除响应数据
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    public func removeResponse(api: String, method: String) {
        let key = generateRequestIndexKey(api: api, method: method)
        let sql = "DELETE FROM responses WHERE key = '\(key)'"
        _ = service.execute(sql: sql, parameters: nil)
    }
    
    /// 清理过期的响应数据
    public func cleanupExpiredResponses() {
        let sql = "DELETE FROM responses WHERE expiration <= \(Date().timeIntervalSince1970)"
        _ = service.execute(sql: sql, parameters: nil)
    }
    
    /// 保存子表响应数据
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - parentId: 父表ID
    ///   - data: 响应数据
    public func saveSubTableResponse(parentTable: String, subTable: String, parentId: String, data: [[String: Any]]) {
        // 保存到数据库
        let columns = data.isEmpty ? [] : Array(data[0].keys)
        let values = data.map { row in
            columns.map { column in
                row[column] ?? NSNull()
            }
        }
        
        if !columns.isEmpty && !values.isEmpty {
            let sql = generateBatchInsertSQL(tableName: subTable, columns: columns, values: values)
            _ = service.execute(sql: sql, parameters: nil)
        }
    }
    
    /// 获取子表响应数据
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - parentId: 父表ID
    /// - Returns: 响应数据
    public func getSubTableResponse(parentTable: String, subTable: String, parentId: String) -> [[String: Any]] {
        let whereClause = "\(parentTable)_id = '\(parentId)'"
        let sql = "SELECT * FROM \(subTable) WHERE \(whereClause)"
        return service.query(sql: sql, parameters: nil)
    }
    
    /// 生成请求索引键
    private func generateRequestIndexKey(api: String, method: String) -> String {
        return "\(api)_\(method)"
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