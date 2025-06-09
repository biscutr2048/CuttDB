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
    func insert(table: String, data: [String: Any]) throws {
        guard var tableData = tables[table] else {
            throw CuttDBError.tableNotFound(table)
        }
        
        // Validate required columns
        let requiredColumns = Set(tableData.first?.keys ?? [])
        let dataColumns = Set(data.keys)
        
        guard requiredColumns.isSubset(of: dataColumns) else {
            throw CuttDBError.invalidData("Missing required columns")
        }
        
        if inTransaction {
            transactionLog.append((table, tableData))
        }
        
        tableData.append(data)
        tables[table] = tableData
    }
    
    /// Update data in a table
    func update(table: String, data: [String: Any], where condition: String) throws {
        guard var tableData = tables[table] else {
            throw CuttDBError.tableNotFound(table)
        }
        
        if inTransaction {
            transactionLog.append((table, tableData))
        }
        
        // Simple condition parsing for testing
        let conditions = condition.components(separatedBy: " AND ")
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
                // Merge the new data with existing row
                var updatedRow = row
                for (key, value) in data {
                    updatedRow[key] = value
                }
                tableData[index] = updatedRow
            }
        }
        
        tables[table] = tableData
    }
    
    /// Delete data from a table
    func delete(table: String, where condition: String) throws {
        guard var tableData = tables[table] else {
            throw CuttDBError.tableNotFound(table)
        }
        
        if inTransaction {
            transactionLog.append((table, tableData))
        }
        
        // Simple condition parsing for testing
        let conditions = condition.components(separatedBy: " AND ")
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
            return matches
        }
        
        tables[table] = tableData
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
} 
