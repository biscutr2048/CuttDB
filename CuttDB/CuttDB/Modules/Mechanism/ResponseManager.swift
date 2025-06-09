import Foundation

/// 响应管理器 - 负责响应数据处理
public struct ResponseManager {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 保存响应数据
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    ///   - data: 响应数据
    ///   - expiration: 过期时间（秒）
    public func saveResponse(api: String, method: String, data: [String: Any], expiration: TimeInterval = 3600) {
        let key = StringUtils.requestIndexKey(api: api, method: method)
        service.setCache(key: key, value: data, expiration: expiration)
    }
    
    /// 获取响应数据
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    /// - Returns: 响应数据
    public func getResponse(api: String, method: String) -> [String: Any]? {
        let key = StringUtils.requestIndexKey(api: api, method: method)
        return service.getCache(key: key)
    }
    
    /// 删除响应数据
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    public func removeResponse(api: String, method: String) {
        let key = StringUtils.requestIndexKey(api: api, method: method)
        service.removeCache(key: key)
    }
    
    /// 清理过期的响应数据
    public func cleanupExpiredResponses() {
        service.cleanupExpiredCache()
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
            _ = service.executeSQL(sql)
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
        return service.query(sql)
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