//
//  CuttDBService.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/5/30.
//

import Foundation
import SQLite3

/// CuttDBService - 内部实现层
/// 处理底层数据库操作和内部模块协调
public protocol CuttDBService {
    // MARK: - 基础操作
    
    /// 执行SQL语句
    /// - Parameter sql: SQL语句
    /// - Returns: 是否成功
    func execute(sql: String) -> Bool
    
    /// 查询数据
    /// - Parameter sql: SQL语句
    /// - Returns: 查询结果
    func query(sql: String) -> [[String: Any]]?
    
    // MARK: - 表管理
    
    /// 检查表是否存在
    /// - Parameter tableName: 表名
    /// - Returns: 是否存在
    func tableExists(_ tableName: String) -> Bool
    
    /// 获取表结构
    /// - Parameter tableName: 表名
    /// - Returns: 表结构
    func getTableStructure(_ tableName: String) -> [String: String]
    
    /// 验证表定义
    /// - Parameters:
    ///   - tableName: 表名
    ///   - expectedDefinition: 期望的表定义
    /// - Returns: 是否匹配
    func validateTableDefinition(tableName: String, expectedDefinition: [String: Any]) -> Bool
    
    // MARK: - 索引管理
    
    /// 创建索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    ///   - columns: 索引列
    /// - Returns: 是否成功
    func createIndex(tableName: String, indexName: String, columns: [String]) -> Bool
    
    /// 删除索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    /// - Returns: 是否成功
    func dropIndex(tableName: String, indexName: String) -> Bool
    
    /// 检查索引是否存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    /// - Returns: 是否存在
    func indexExists(tableName: String, indexName: String) -> Bool
    
    // MARK: - 事务管理
    
    /// 开始事务
    func beginTransaction()
    
    /// 提交事务
    func commitTransaction()
    
    /// 回滚事务
    func rollbackTransaction()
    
    // MARK: - 缓存管理
    
    /// 设置缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - value: 缓存值
    ///   - expiration: 过期时间（秒）
    func setCache(key: String, value: Any, expiration: Int)
    
    /// 获取缓存
    /// - Parameter key: 缓存键
    /// - Returns: 缓存值
    func getCache(key: String) -> Any?
    
    /// 删除缓存
    /// - Parameter key: 缓存键
    func removeCache(key: String)
    
    /// 清理过期缓存
    func cleanupExpiredCache()
}

/// 默认实现
public extension CuttDBService {
    func validateTableDefinition(tableName: String, expectedDefinition: [String: Any]) -> Bool {
        let structure = getTableStructure(tableName)
        // 实现表定义验证逻辑
        return true
    }
    
    func indexExists(tableName: String, indexName: String) -> Bool {
        let sql = "SELECT 1 FROM sys.indexes WHERE name = '\(indexName)' AND object_id = OBJECT_ID('\(tableName)')"
        return query(sql: sql)?.count ?? 0 > 0
    }
    
    func setCache(key: String, value: Any, expiration: Int) {
        // 实现缓存设置逻辑
    }
    
    func getCache(key: String) -> Any? {
        // 实现缓存获取逻辑
        return nil
    }
    
    func removeCache(key: String) {
        // 实现缓存删除逻辑
    }
    
    func cleanupExpiredCache() {
        // 实现过期缓存清理逻辑
    }
}

/// CuttDBService的具体实现
public class DefaultCuttDBService: CuttDBService {
    private var db: OpaquePointer?
    private var cache: [String: (value: Any, expiration: Date)] = [:]
    private let cacheQueue = DispatchQueue(label: "com.cuttdb.cache")
    
    public init(dbPath: String) {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("无法打开数据库")
        }
    }
    
    deinit {
        if let db = db {
            sqlite3_close(db)
        }
    }
    
    // MARK: - 基础操作
    
    public func execute(sql: String) -> Bool {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            let result = sqlite3_step(statement) == SQLITE_DONE
            sqlite3_finalize(statement)
            return result
        }
        return false
    }
    
    public func query(sql: String) -> [[String: Any]]? {
        var statement: OpaquePointer?
        var results: [[String: Any]] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var row: [String: Any] = [:]
                let columns = sqlite3_column_count(statement)
                
                for i in 0..<columns {
                    if let name = sqlite3_column_name(statement, i) {
                        let columnName = String(cString: name)
                        let type = sqlite3_column_type(statement, i)
                        
                        switch type {
                        case SQLITE_INTEGER:
                            row[columnName] = sqlite3_column_int64(statement, i)
                        case SQLITE_FLOAT:
                            row[columnName] = sqlite3_column_double(statement, i)
                        case SQLITE_TEXT:
                            if let text = sqlite3_column_text(statement, i) {
                                row[columnName] = String(cString: text)
                            }
                        case SQLITE_BLOB:
                            if let blob = sqlite3_column_blob(statement, i) {
                                let size = sqlite3_column_bytes(statement, i)
                                row[columnName] = Data(bytes: blob, count: Int(size))
                            }
                        case SQLITE_NULL:
                            row[columnName] = NSNull()
                        default:
                            break
                        }
                    }
                }
                results.append(row)
            }
            sqlite3_finalize(statement)
        }
        return results.isEmpty ? nil : results
    }
    
    // MARK: - 表管理
    
    public func tableExists(_ tableName: String) -> Bool {
        let sql = "SELECT name FROM sqlite_master WHERE type='table' AND name='\(tableName)'"
        return query(sql: sql)?.count ?? 0 > 0
    }
    
    public func getTableStructure(_ tableName: String) -> [String: String] {
        var structure: [String: String] = [:]
        let sql = "PRAGMA table_info(\(tableName))"
        
        if let results = query(sql: sql) {
            for row in results {
                if let name = row["name"] as? String,
                   let type = row["type"] as? String {
                    structure[name] = type
                }
            }
        }
        return structure
    }
    
    // MARK: - 索引管理
    
    public func createIndex(tableName: String, indexName: String, columns: [String]) -> Bool {
        let columnsStr = columns.joined(separator: ", ")
        let sql = "CREATE INDEX IF NOT EXISTS \(indexName) ON \(tableName) (\(columnsStr))"
        return execute(sql: sql)
    }
    
    public func dropIndex(tableName: String, indexName: String) -> Bool {
        let sql = "DROP INDEX IF EXISTS \(indexName)"
        return execute(sql: sql)
    }
    
    // MARK: - 事务管理
    
    public func beginTransaction() {
        execute(sql: "BEGIN TRANSACTION")
    }
    
    public func commitTransaction() {
        execute(sql: "COMMIT")
    }
    
    public func rollbackTransaction() {
        execute(sql: "ROLLBACK")
    }
    
    // MARK: - 缓存管理
    
    public func setCache(key: String, value: Any, expiration: Int) {
        cacheQueue.async {
            let expirationDate = Date().addingTimeInterval(TimeInterval(expiration))
            self.cache[key] = (value: value, expiration: expirationDate)
        }
    }
    
    public func getCache(key: String) -> Any? {
        var result: Any?
        cacheQueue.sync {
            if let (value, expiration) = self.cache[key],
               expiration > Date() {
                result = value
            } else {
                self.cache.removeValue(forKey: key)
            }
        }
        return result
    }
    
    public func removeCache(key: String) {
        cacheQueue.async {
            self.cache.removeValue(forKey: key)
        }
    }
    
    public func cleanupExpiredCache() {
        cacheQueue.async {
            let now = Date()
            self.cache = self.cache.filter { $0.value.expiration > now }
        }
    }
} 
