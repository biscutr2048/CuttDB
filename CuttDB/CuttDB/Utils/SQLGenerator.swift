import Foundation

/// SQL生成器
struct SQLGenerator {
    /// 生成创建表SQL
    static func generateCreateTableSQL(tableName: String, columns: [String]) -> String {
        return """
            CREATE TABLE IF NOT EXISTS \(tableName) (
                \(columns.joined(separator: ", "))
            );
        """
    }
    
    /// 生成插入SQL
    static func generateInsertSQL(tableName: String, values: [String: Any]) -> String {
        let columns = values.keys.joined(separator: ", ")
        let placeholders = values.keys.map { "@\($0)" }.joined(separator: ", ")
        return "INSERT INTO \(tableName) (\(columns)) VALUES (\(placeholders))"
    }
    
    /// 生成更新SQL
    static func generateUpdateSQL(tableName: String, values: [String: Any], whereClause: String) -> String {
        let setClause = values.keys.map { "\($0) = @\($0)" }.joined(separator: ", ")
        return "UPDATE \(tableName) SET \(setClause) WHERE \(whereClause)"
    }
    
    /// 生成查询SQL
    static func generateSelectSQL(
        tableName: String,
        columns: [String] = ["*"],
        whereClause: String? = nil,
        orderBy: String? = nil,
        limit: Int? = nil,
        offset: Int? = nil
    ) -> String {
        var sql = "SELECT \(columns.joined(separator: ", ")) FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        if let orderBy = orderBy {
            sql += " ORDER BY \(orderBy)"
        }
        
        if let limit = limit {
            sql += " LIMIT \(limit)"
            if let offset = offset {
                sql += " OFFSET \(offset)"
            }
        }
        
        return sql
    }
    
    /// 生成计数SQL
    static func generateCountSQL(tableName: String, whereClause: String? = nil) -> String {
        var sql = "SELECT COUNT(*) as count FROM \(tableName)"
        
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        
        return sql
    }
    
    /// 生成删除SQL
    static func generateDeleteSQL(tableName: String, whereClause: String) -> String {
        return "DELETE FROM \(tableName) WHERE \(whereClause)"
    }
    
    /// 生成批量插入SQL
    static func generateBatchInsertSQL(tableName: String, columns: [String], values: [[Any]]) -> String {
        let columnsStr = columns.joined(separator: ", ")
        let placeholders = values.map { row in
            "(" + row.map { _ in "?" }.joined(separator: ", ") + ")"
        }.joined(separator: ", ")
        
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES \(placeholders)"
    }
} 