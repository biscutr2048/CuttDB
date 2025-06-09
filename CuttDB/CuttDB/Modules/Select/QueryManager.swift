//
//  QueryManager.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 查询管理器 - 负责数据查询操作
internal struct QueryManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 查询数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 要查询的列
    ///   - whereClause: WHERE 子句
    ///   - parameters: 参数
    /// - Returns: 查询结果
    func query(tableName: String, columns: [String] = ["*"], whereClause: String? = nil, parameters: [Any]? = nil) -> [[String: Any]] {
        let columnsStr = columns.joined(separator: ", ")
        var sql = "SELECT \(columnsStr) FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        return service.query(sql: sql, parameters: parameters)
    }
    
    /// 分页查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - page: 页码
    ///   - pageSize: 每页大小
    ///   - columns: 要查询的列
    ///   - whereClause: WHERE 子句
    ///   - parameters: 参数
    ///   - orderBy: 排序字段
    /// - Returns: 分页结果
    func queryWithPagination(tableName: String, page: Int, pageSize: Int, columns: [String] = ["*"], whereClause: String? = nil, parameters: [Any]? = nil, orderBy: String? = nil) -> [[String: Any]] {
        let offset = (page - 1) * pageSize
        let columnsStr = columns.joined(separator: ", ")
        var sql = "SELECT \(columnsStr) FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        if let orderBy = orderBy {
            sql += " ORDER BY \(orderBy)"
        }
        
        sql += " LIMIT \(pageSize) OFFSET \(offset)"
        
        return service.query(sql: sql, parameters: parameters)
    }
    
    /// 获取总记录数
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: WHERE 子句
    ///   - parameters: 参数
    /// - Returns: 总记录数
    func getTotalCount(tableName: String, whereClause: String? = nil, parameters: [Any]? = nil) -> Int {
        var sql = "SELECT COUNT(*) as count FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        let result = service.query(sql: sql, parameters: parameters)
        return result.first?["count"] as? Int ?? 0
    }
    
    /// 查询单个对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 对象ID
    /// - Returns: 对象数据
    func queryObject(tableName: String, id: String) -> [String: Any]? {
        let sql = "SELECT * FROM \(tableName) WHERE id = ?"
        let result = service.query(sql: sql, parameters: [id])
        return result.first
    }
    
    /// 检查记录是否存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: WHERE 子句
    ///   - parameters: 参数
    /// - Returns: 是否存在
    func exists(tableName: String, whereClause: String, parameters: [Any]? = nil) -> Bool {
        let sql = "SELECT 1 FROM \(tableName) WHERE \(whereClause) LIMIT 1"
        let result = service.query(sql: sql, parameters: parameters)
        return !result.isEmpty
    }
} 