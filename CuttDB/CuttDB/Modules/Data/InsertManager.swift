import Foundation

/// 插入管理器 - 负责数据插入操作
public struct InsertManager {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 插入单个对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - values: 要插入的值
    /// - Returns: 是否插入成功
    public func insert(tableName: String, values: [String: Any]) -> Bool {
        let sql = generateInsertSQL(tableName: tableName, values: values)
        return service.executeSQL(sql)
    }
    
    /// 插入子表数据
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - parentId: 父表ID
    ///   - values: 要插入的值
    /// - Returns: 是否插入成功
    public func insertSubTable(parentTable: String, subTable: String, parentId: String, values: [String: Any]) -> Bool {
        var newValues = values
        newValues["\(parentTable)_id"] = parentId
        return insert(tableName: subTable, values: newValues)
    }
    
    /// 生成插入SQL
    private func generateInsertSQL(tableName: String, values: [String: Any]) -> String {
        let columns = values.keys.map { StringUtils.escapeSQLString($0) }
        let placeholders = values.values.map { value in
            if let stringValue = value as? String {
                return "'\(StringUtils.escapeSQLString(stringValue))'"
            } else {
                return "\(value)"
            }
        }
        
        let columnsStr = columns.joined(separator: ", ")
        let valuesStr = placeholders.joined(separator: ", ")
        
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES (\(valuesStr))"
    }
} 