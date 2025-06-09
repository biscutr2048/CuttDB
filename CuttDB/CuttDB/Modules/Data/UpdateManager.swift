//
//  UpdateManager.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 更新管理器 - 负责数据更新操作
internal struct UpdateManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - values: 更新的值
    ///   - whereClause: 更新条件
    /// - Returns: 是否更新成功
    func update(tableName: String, values: [String: Any], whereClause: String) -> Bool {
        let sql = generateUpdateSQL(tableName: tableName, values: values, whereClause: whereClause)
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 根据ID更新数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 对象ID
    ///   - values: 更新的值
    /// - Returns: 是否更新成功
    func updateById(tableName: String, id: String, values: [String: Any]) -> Bool {
        return update(tableName: tableName, values: values, whereClause: "id = '\(id)'")
    }
    
    /// 更新子表数据
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - parentId: 父表ID
    ///   - values: 要更新的值
    ///   - whereClause: 更新条件
    /// - Returns: 是否更新成功
    public func updateSubTable(parentTable: String, subTable: String, parentId: String, values: [String: Any], whereClause: String) -> Bool {
        let fullWhereClause = "\(parentTable)_id = '\(parentId)' AND \(whereClause)"
        return update(tableName: subTable, values: values, whereClause: fullWhereClause)
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