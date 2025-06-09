import Foundation
@testable import CuttDB

/// Mock implementation of CuttDBService for testing
class MockCuttDBService: CuttDBService {
    // MARK: - Properties
    
    /// Configuration for the mock service
    private let configuration: CuttDBServiceConfiguration
    
    /// In-memory storage for tables
    private var tables: [String: [[String: Any]]] = [:]
    
    /// In-memory storage for indexes
    private var indexes: [String: [String]] = [:]
    
    /// Current transaction state
    private var inTransaction = false
    
    /// Transaction log
    private var transactionLog: [(String, [[String: Any]])] = []
    
    // MARK: - Initialization
    
    /// Initialize with configuration
    init(configuration: CuttDBServiceConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - CuttDBService Protocol Implementation
    
    /// Execute SQL query
    func query(sql: String, parameters: [Any]?) -> [[String: Any]] {
        // Simple SQL parsing for testing
        if sql.lowercased().contains("select") {
            if sql.lowercased().contains("count") {
                return [["count": tables.values.first?.count ?? 0]]
            }
            return tables.values.first ?? []
        }
        return []
    }
    
    /// Execute SQL command
    func execute(sql: String, parameters: [Any]?) -> Int {
        // Simple SQL parsing for testing
        if sql.lowercased().contains("insert") {
            return 1
        } else if sql.lowercased().contains("update") {
            return 1
        } else if sql.lowercased().contains("delete") {
            return 1
        }
        return 0
    }
    
    /// Begin transaction
    func beginTransaction() {
        inTransaction = true
        transactionLog.removeAll()
    }
    
    /// Commit transaction
    func commit() {
        inTransaction = false
        transactionLog.removeAll()
    }
    
    /// Rollback transaction
    func rollback() {
        // Restore table states from transaction log
        for (table, data) in transactionLog {
            tables[table] = data
        }
        
        inTransaction = false
        transactionLog.removeAll()
    }
    
    /// Create table
    func createTable(name: String, columns: [String: String]) -> Bool {
        guard !tables.keys.contains(name) else {
            return false
        }
        
        tables[name] = []
        indexes[name] = []
        return true
    }
    
    /// Drop table
    func dropTable(name: String) -> Bool {
        guard tables.keys.contains(name) else {
            return false
        }
        
        tables.removeValue(forKey: name)
        indexes.removeValue(forKey: name)
        return true
    }
    
    /// Check if table exists
    func tableExists(name: String) -> Bool {
        return tables.keys.contains(name)
    }
    
    /// Get table schema
    func getTableSchema(name: String) -> [String: String] {
        guard let tableData = tables[name], let firstRow = tableData.first else {
            return [:]
        }
        
        // Create schema dictionary directly from the first row
        var schema: [String: String] = [:]
        for (key, _) in firstRow {
            schema[key] = "TEXT"
        }
        return schema
    }
    
    /// Set mock data
    func setMockData(for table: String, data: [[String: Any]]) {
        tables[table] = data
    }
    
    /// Get mock data
    func getMockData(for table: String) -> [[String: Any]] {
        return tables[table] ?? []
    }
    
    // MARK: - Table Operations
    
    /// List all tables
    func listTables() throws -> [String] {
        return Array(tables.keys)
    }
    
    // MARK: - Data Operations
    
    /// Insert data into a table
    func insert(table: String, data: [String: Any]) throws -> Bool {
        guard var tableData = tables[table] else {
            throw CuttDBError.tableNotFound(table)
        }
        
        tableData.append(data)
        tables[table] = tableData
        return true
    }
    
    /// Update data in a table
    func update(table: String, data: [String: Any], where condition: String) throws -> Bool {
        guard var tableData = tables[table] else {
            throw CuttDBError.tableNotFound(table)
        }
        
        // Simple condition parsing for testing
        let conditions = condition.components(separatedBy: " AND ")
        var updated = false
        
        for (index, row) in tableData.enumerated() {
            var matches = true
            for condition in conditions {
                let parts = condition.components(separatedBy: "=")
                guard parts.count == 2 else { continue }
                
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                
                if let rowValue = row[key] {
                    if String(describing: rowValue) != value {
                        matches = false
                        break
                    }
                } else {
                    matches = false
                    break
                }
            }
            
            if matches {
                var updatedRow = row
                for (key, value) in data {
                    updatedRow[key] = value
                }
                tableData[index] = updatedRow
                updated = true
            }
        }
        
        if updated {
            tables[table] = tableData
        }
        
        return updated
    }
    
    /// Delete data from a table
    func delete(table: String, where condition: String) throws -> Bool {
        guard var tableData = tables[table] else {
            throw CuttDBError.tableNotFound(table)
        }
        
        // Simple condition parsing for testing
        let conditions = condition.components(separatedBy: " AND ")
        var deleted = false
        
        tableData.removeAll { row in
            var matches = true
            for condition in conditions {
                let parts = condition.components(separatedBy: "=")
                guard parts.count == 2 else { continue }
                
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                
                if let rowValue = row[key] {
                    if String(describing: rowValue) != value {
                        matches = false
                        break
                    }
                } else {
                    matches = false
                    break
                }
            }
            
            if matches {
                deleted = true
                return true
            }
            return false
        }
        
        if deleted {
            tables[table] = tableData
        }
        
        return deleted
    }
    
    /// Query data from a table
    func query(table: String, where condition: String? = nil) throws -> [[String: Any]] {
        guard let tableData = tables[table] else {
            throw CuttDBError.tableNotFound(table)
        }
        
        guard let condition = condition else {
            return tableData
        }
        
        // Simple condition parsing for testing
        let conditions = condition.components(separatedBy: " AND ")
        return tableData.filter { row in
            var matches = true
            for condition in conditions {
                let parts = condition.components(separatedBy: "=")
                guard parts.count == 2 else { continue }
                
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                
                if let rowValue = row[key] {
                    if String(describing: rowValue) != value {
                        matches = false
                        break
                    }
                } else {
                    matches = false
                    break
                }
            }
            return matches
        }
    }
    
    // MARK: - Index Operations
    
    /// Create an index
    func createIndex(on table: String, columns: [String]) -> Bool {
        guard tables.keys.contains(table) else {
            return false
        }
        
        guard var tableIndexes = indexes[table] else {
            return false
        }
        
        let indexName = columns.joined(separator: "_")
        guard !tableIndexes.contains(indexName) else {
            return false
        }
        
        tableIndexes.append(indexName)
        indexes[table] = tableIndexes
        return true
    }
    
    /// List indexes for a table
    func listIndexes(for table: String) -> [String] {
        return indexes[table] ?? []
    }
    
    // MARK: - Utility Methods
    
    /// Get the current database version
    func getVersion() throws -> Int {
        return 1
    }
    
    /// Upgrade the database to a new version
    func upgrade(from oldVersion: Int, to newVersion: Int) throws {
        // Mock implementation
    }
    
    /// Close the database connection
    func close() {
        tables.removeAll()
        indexes.removeAll()
        transactionLog.removeAll()
        inTransaction = false
    }
    
    // MARK: - Private Helper Methods
    
    private func extractTableName(from sql: String) -> String {
        let components = sql.components(separatedBy: " ")
        if let fromIndex = components.firstIndex(of: "from") {
            return components[fromIndex + 1].trimmingCharacters(in: .whitespaces)
        }
        if let intoIndex = components.firstIndex(of: "into") {
            return components[intoIndex + 1].trimmingCharacters(in: .whitespaces)
        }
        return ""
    }
    
    private func extractWhereClause(from sql: String) -> String? {
        guard let whereRange = sql.range(of: "where", options: .caseInsensitive) else {
            return nil
        }
        let whereClause = sql[whereRange.upperBound...]
        if let orderByRange = whereClause.range(of: "order by", options: .caseInsensitive) {
            return String(whereClause[..<orderByRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        if let limitRange = whereClause.range(of: "limit", options: .caseInsensitive) {
            return String(whereClause[..<limitRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        return String(whereClause).trimmingCharacters(in: .whitespaces)
    }
    
    private func extractOrderBy(from sql: String) -> String? {
        guard let orderByRange = sql.range(of: "order by", options: .caseInsensitive) else {
            return nil
        }
        let orderBy = sql[orderByRange.upperBound...]
        if let limitRange = orderBy.range(of: "limit", options: .caseInsensitive) {
            return String(orderBy[..<limitRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        }
        return String(orderBy).trimmingCharacters(in: .whitespaces)
    }
    
    private func extractLimitAndOffset(from sql: String) -> (limit: Int, offset: Int)? {
        guard let limitRange = sql.range(of: "limit", options: .caseInsensitive) else {
            return nil
        }
        let limitStr = sql[limitRange.upperBound...]
        let components = limitStr.components(separatedBy: " ")
        guard let limit = Int(components[0]) else { return nil }
        
        if components.count > 2 && components[1].lowercased() == "offset" {
            guard let offset = Int(components[2]) else { return nil }
            return (limit, offset)
        }
        
        return (limit, 0)
    }
    
    private func extractInsertValues(from sql: String) -> [String: Any]? {
        guard let valuesRange = sql.range(of: "values", options: .caseInsensitive) else {
            return nil
        }
        let valuesStr = sql[valuesRange.upperBound...]
        let components = valuesStr.components(separatedBy: ",")
        var values: [String: Any] = [:]
        
        for component in components {
            let parts = component.trimmingCharacters(in: .whitespaces).components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                values[key] = value
            }
        }
        
        return values
    }
    
    private func extractUpdateValues(from sql: String) -> (values: [String: Any], whereClause: String)? {
        guard let setRange = sql.range(of: "set", options: .caseInsensitive),
              let whereRange = sql.range(of: "where", options: .caseInsensitive) else {
            return nil
        }
        
        let setStr = sql[setRange.upperBound..<whereRange.lowerBound]
        let whereClause = String(sql[whereRange.upperBound...]).trimmingCharacters(in: .whitespaces)
        
        var values: [String: Any] = [:]
        let setComponents = setStr.components(separatedBy: ",")
        
        for component in setComponents {
            let parts = component.trimmingCharacters(in: .whitespaces).components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                values[key] = value
            }
        }
        
        return (values, whereClause)
    }
    
    private func filterData(_ data: [[String: Any]], whereClause: String, parameters: [Any]?) -> [[String: Any]] {
        return data.filter { row in
            matchesWhereClause(row, whereClause: whereClause, parameters: parameters)
        }
    }
    
    private func matchesWhereClause(_ row: [String: Any], whereClause: String, parameters: [Any]?) -> Bool {
        let conditions = whereClause.components(separatedBy: " and ")
        for condition in conditions {
            let parts = condition.components(separatedBy: "=")
            guard parts.count == 2 else { continue }
            
            let key = parts[0].trimmingCharacters(in: .whitespaces)
            let value = parts[1].trimmingCharacters(in: .whitespaces)
            
            if let rowValue = row[key] {
                if String(describing: rowValue) != value {
                    return false
                }
            } else {
                return false
            }
        }
        return true
    }
    
    private func sortData(_ data: [[String: Any]], orderBy: String) -> [[String: Any]] {
        let components = orderBy.components(separatedBy: " ")
        guard components.count >= 1 else { return data }
        
        let key = components[0]
        let ascending = components.count < 2 || components[1].lowercased() != "desc"
        
        return data.sorted { row1, row2 in
            guard let value1 = row1[key], let value2 = row2[key] else {
                return false
            }
            
            if let str1 = value1 as? String, let str2 = value2 as? String {
                return ascending ? str1 < str2 : str1 > str2
            }
            
            if let num1 = value1 as? Int, let num2 = value2 as? Int {
                return ascending ? num1 < num2 : num1 > num2
            }
            
            return false
        }
    }
} 
