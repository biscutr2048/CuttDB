import Foundation

/// 字符串工具类
struct StringUtils {
    /// 生成请求索引键
    static func requestIndexKey(api: String, method: String) -> String {
        return "\(method)_\(api)".replacingOccurrences(of: "/", with: "_")
    }
    
    /// 转义SQL字符串
    static func escapeSQLString(_ string: String) -> String {
        return string.replacingOccurrences(of: "'", with: "''")
    }
    
    /// 生成表名
    static func generateTableName(prefix: String, suffix: String? = nil) -> String {
        if let suffix = suffix {
            return "\(prefix)_\(suffix)"
        }
        return prefix
    }
    
    /// 生成列名
    static func generateColumnName(_ name: String) -> String {
        return name.lowercased().replacingOccurrences(of: " ", with: "_")
    }
    
    /// 生成索引名
    static func generateIndexName(tableName: String, columns: [String]) -> String {
        let columnsStr = columns.joined(separator: "_")
        return "idx_\(tableName)_\(columnsStr)"
    }
} 