//
//  PagedQuery.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 分页查询管理器 - 负责分页数据查询
internal struct PagedQuery {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 执行分页查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - page: 页码
    ///   - pageSize: 每页大小
    ///   - whereClause: WHERE 子句
    ///   - orderBy: 排序字段
    /// - Returns: 分页结果
    func queryPaged(from tableName: String, page: Int, pageSize: Int, where whereClause: String? = nil, orderBy: String? = nil) -> [[String: Any]] {
        let offset = (page - 1) * pageSize
        
        // 构建查询SQL
        var sql = "SELECT * FROM \(tableName)"
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        if let orderBy = orderBy {
            sql += " ORDER BY \(orderBy)"
        }
        sql += " LIMIT \(pageSize) OFFSET \(offset)"
        
        return service.query(sql: sql, parameters: nil)
    }
    
    /// 获取总记录数
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: WHERE 子句
    /// - Returns: 总记录数
    func getTotalCount(from tableName: String, where whereClause: String? = nil) -> Int {
        var sql = "SELECT COUNT(*) as count FROM \(tableName)"
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        let result = service.query(sql: sql, parameters: nil)
        return result.first?["count"] as? Int ?? 0
    }
} 