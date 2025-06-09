//
//  ObjectQuery.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

/// 对象查询 - 负责对象查询操作
internal struct ObjectQuery {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 查询对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    ///   - type: 对象类型
    /// - Returns: 查询结果
    func queryObjects<T: Decodable>(tableName: String, whereClause: String, type: T.Type) -> [T] {
        let sql = "SELECT * FROM \(tableName) WHERE \(whereClause)"
        let results = service.query(sql: sql, parameters: nil)
        
        return results.compactMap { row in
            do {
                let data = try JSONSerialization.data(withJSONObject: row)
                return try JSONDecoder().decode(type, from: data)
            } catch {
                return nil
            }
        }
    }
    
    /// 分页查询对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    ///   - page: 页码
    ///   - pageSize: 每页大小
    ///   - type: 对象类型
    /// - Returns: 查询结果
    func queryObjectsWithPaging<T: Decodable>(
        tableName: String,
        whereClause: String,
        page: Int,
        pageSize: Int,
        type: T.Type
    ) -> [T] {
        let offset = (page - 1) * pageSize
        let sql = "SELECT * FROM \(tableName) WHERE \(whereClause) LIMIT \(pageSize) OFFSET \(offset)"
        let results = service.query(sql: sql, parameters: nil)
        
        return results.compactMap { row in
            do {
                let data = try JSONSerialization.data(withJSONObject: row)
                return try JSONDecoder().decode(type, from: data)
            } catch {
                return nil
            }
        }
    }
} 