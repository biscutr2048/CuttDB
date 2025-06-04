//
//  CuttDBService.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/5/30.
//

import Foundation
import SQLite3

class CuttDBService {
    private var db: OpaquePointer?
    private let dbPath: String
    
    init(dbName: String = "cuttDB.sqlite") {
        // 获取应用程序的文档目录
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        dbPath = documentsPath.appendingPathComponent(dbName).path
        
        // 打开数据库连接
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print("Successfully opened connection to database at \(dbPath)")
        } else {
            print("Unable to open database. Verify that you created the directory correctly")
        }
    }
    
    deinit {
        // 关闭数据库连接
        if sqlite3_close(db) == SQLITE_OK {
            print("Database connection closed")
        } else {
            print("Error closing database connection")
        }
    }
    
    // MARK: - 数据库操作
    
    /// 检查表是否存在
    private func tableExists(_ tableName: String) -> Bool {
        let results = select(
            tableName: "sqlite_master",
            columns: ["name"],
            whereClause: "type='table' AND name='\(tableName)'"
        )
        return !results.isEmpty
    }
    
    /// 确保表存在，如果不存在则创建
    private func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        if !tableExists(tableName) {
            // 表不存在，创建表
            if createTable(tableName: tableName, columns: columns) {
                print("Table \(tableName) created successfully")
                return true
            } else {
                print("Failed to create table \(tableName)")
                return false
            }
        }
        return true
    }
    
    /// 执行数据库操作，确保表存在
    func executeWithTable(tableName: String, columns: [String], operation: () -> Bool) -> Bool {
        if ensureTableExists(tableName: tableName, columns: columns) {
            return operation()
        }
        return false
    }
    
    /// 执行 SQL 语句
    func executeQuery(_ query: String) -> Bool {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        if let errorMessage = String(validatingUTF8: sqlite3_errmsg(db)) {
            print("Error executing query: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    /// 创建表
    func createTable(tableName: String, columns: [String]) -> Bool {
        let query = """
            CREATE TABLE IF NOT EXISTS \(tableName) (
                \(columns.joined(separator: ", "))
            );
        """
        return executeQuery(query)
    }
    
    /// 插入数据
    func insert(tableName: String, values: [String: Any]) -> Bool {
        let columns = values.keys.joined(separator: ", ")
        let placeholders = String(repeating: "?,", count: values.count - 1) + "?"
        let query = "INSERT INTO \(tableName) (\(columns)) VALUES (\(placeholders))"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            var index: Int32 = 1
            for (_, value) in values {
                if let text = value as? String {
                    sqlite3_bind_text(statement, index, (text as NSString).utf8String, -1, nil)
                } else if let int = value as? Int {
                    sqlite3_bind_int64(statement, index, Int64(int))
                } else if let double = value as? Double {
                    sqlite3_bind_double(statement, index, double)
                }
                index += 1
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        if let errorMessage = String(validatingUTF8: sqlite3_errmsg(db)) {
            print("Error inserting data: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    /// 查询数据
    func select(tableName: String, columns: [String] = ["*"], whereClause: String? = nil, orderBy: String? = nil) -> [[String: Any]] {
        var results: [[String: Any]] = []
        let columnsStr = columns.joined(separator: ", ")
        var query = "SELECT \(columnsStr) FROM \(tableName)"
        
        if let whereClause = whereClause {
            query += " WHERE \(whereClause)"
        }
        
        if let orderBy = orderBy {
            query += " ORDER BY \(orderBy)"
        }
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                var row: [String: Any] = [:]
                
                for i in 0..<sqlite3_column_count(statement) {
                    if let columnName = sqlite3_column_name(statement, i),
                       let name = String(validatingUTF8: columnName) {
                        let type = sqlite3_column_type(statement, i)
                        
                        switch type {
                        case SQLITE_INTEGER:
                            row[name] = sqlite3_column_int64(statement, i)
                        case SQLITE_FLOAT:
                            row[name] = sqlite3_column_double(statement, i)
                        case SQLITE_TEXT:
                            if let text = sqlite3_column_text(statement, i) {
                                row[name] = String(cString: text)
                            }
                        case SQLITE_NULL:
                            row[name] = NSNull()
                        default:
                            break
                        }
                    }
                }
                
                results.append(row)
            }
        }
        
        sqlite3_finalize(statement)
        return results
    }
    
    /// 更新数据
    func update(tableName: String, values: [String: Any], whereClause: String) -> Bool {
        let setClause = values.keys.map { "\($0) = ?" }.joined(separator: ", ")
        let query = "UPDATE \(tableName) SET \(setClause) WHERE \(whereClause)"
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            var index: Int32 = 1
            for (_, value) in values {
                if let text = value as? String {
                    sqlite3_bind_text(statement, index, (text as NSString).utf8String, -1, nil)
                } else if let int = value as? Int {
                    sqlite3_bind_int64(statement, index, Int64(int))
                } else if let double = value as? Double {
                    sqlite3_bind_double(statement, index, double)
                }
                index += 1
            }
            
            if sqlite3_step(statement) == SQLITE_DONE {
                sqlite3_finalize(statement)
                return true
            }
        }
        
        if let errorMessage = String(validatingUTF8: sqlite3_errmsg(db)) {
            print("Error updating data: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        return false
    }
    
    /// 删除数据
    func delete(tableName: String, whereClause: String) -> Bool {
        let query = "DELETE FROM \(tableName) WHERE \(whereClause)"
        return executeQuery(query)
    }
    
    /// 获取表结构
    func getTableColumns(tableName: String) -> [(name: String, type: String)]? {
        let query = "PRAGMA table_info(\(tableName))"
        var columns: [(name: String, type: String)] = []
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                // cid, name, type, notnull, dflt_value, pk
                if let namePtr = sqlite3_column_text(statement, 1),
                   let typePtr = sqlite3_column_text(statement, 2) {
                    let name = String(cString: namePtr)
                    let type = String(cString: typePtr)
                    columns.append((name: name, type: type))
                }
            }
            sqlite3_finalize(statement)
            return columns
        }
        
        if let errorMessage = String(validatingUTF8: sqlite3_errmsg(db)) {
            print("Error getting table structure: \(errorMessage)")
        }
        
        sqlite3_finalize(statement)
        return nil
    }
    
    /// 判断某表主键值是否已存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - primaryKey: 主键字段名，默认"id"
    ///   - value: 主键值
    /// - Returns: 存在返回true，否则false
    func primaryKeyExists(tableName: String, primaryKey: String = "id", value: Any) -> Bool {
        let whereClause = "\(primaryKey) = '" + String(describing: value) + "'"
        let results = select(tableName: tableName, columns: [primaryKey], whereClause: whereClause)
        return !results.isEmpty
    }
    
    /// 恢复最近一次response数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    /// - Returns: 最近一次应答数据（[String: Any]），无数据返回nil
    func restoreLastResponse(api: String, method: String) -> [String: Any]? {
        let tableName = CuttDB.requestIndexKey(api: api, method: method)
        // 优先按created_at、id倒序，取最新一条
        let results = select(tableName: tableName, columns: ["*"], whereClause: nil, orderBy: "created_at DESC, id DESC")
        return results.first
    }
    
    /// 恢复子表的response数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - property: 列表属性名
    /// - Returns: 子表所有数据数组（[[String: Any]]），无数据返回空数组
    func restoreSubTableResponse(api: String, method: String, property: String) -> [[String: Any]] {
        let mainTable = CuttDB.requestIndexKey(api: api, method: method)
        let subTable = "\(mainTable)-sub-\(property)"
        return select(tableName: subTable, columns: ["*"])
    }
} 
