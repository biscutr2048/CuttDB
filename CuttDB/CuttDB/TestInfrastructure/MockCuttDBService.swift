import Foundation

/// 模拟数据库服务
/// 用于测试环境，模拟数据库操作
class MockCuttDBService {
    // MARK: - 配置属性
    
    /// 是否应该让键存在（用于测试更新操作）
    var shouldKeyExist: Bool = false
    
    /// 是否应该模拟错误
    var shouldSimulateError: Bool = false
    
    /// 模拟延迟（毫秒）
    var simulatedDelay: Int = 0
    
    /// 模拟错误消息
    var errorMessage: String = "模拟错误"
    
    // MARK: - 内部状态
    
    /// 存储模拟数据
    private var mockData: [String: Any] = [:]
    
    /// 存储模拟表结构
    private var mockTables: [String: [String: String]] = [:]
    
    /// 存储模拟索引
    private var mockIndexes: [String: [String]] = [:]
    
    // MARK: - 初始化方法
    
    /// 创建模拟数据库服务实例
    init() {
        setupDefaultMockData()
    }
    
    /// 设置默认的模拟数据
    private func setupDefaultMockData() {
        // 设置默认表结构
        mockTables["users"] = [
            "id": "INTEGER",
            "name": "TEXT",
            "email": "TEXT",
            "created_at": "TEXT"
        ]
        
        // 设置默认索引
        mockIndexes["users"] = ["email"]
        
        // 设置默认数据
        mockData["users"] = [
            [
                "id": 1,
                "name": "Test User",
                "email": "test@example.com",
                "created_at": "2024-03-20"
            ]
        ]
    }
    
    // MARK: - 公共方法
    
    /// 执行SQL查询
    /// - Parameters:
    ///   - sql: SQL语句
    ///   - parameters: 参数
    /// - Returns: 查询结果
    func executeQuery(sql: String, parameters: [Any] = []) -> [[String: Any]]? {
        if shouldSimulateError {
            return nil
        }
        
        // 模拟查询延迟
        if simulatedDelay > 0 {
            Thread.sleep(forTimeInterval: TimeInterval(simulatedDelay) / 1000.0)
        }
        
        // 根据SQL类型返回不同的模拟数据
        if sql.lowercased().contains("select") {
            return mockData["users"] as? [[String: Any]]
        }
        
        return []
    }
    
    /// 执行SQL更新
    /// - Parameters:
    ///   - sql: SQL语句
    ///   - parameters: 参数
    /// - Returns: 是否成功
    func executeUpdate(sql: String, parameters: [Any] = []) -> Bool {
        if shouldSimulateError {
            return false
        }
        
        // 模拟更新延迟
        if simulatedDelay > 0 {
            Thread.sleep(forTimeInterval: TimeInterval(simulatedDelay) / 1000.0)
        }
        
        return true
    }
    
    /// 获取表结构
    /// - Parameter tableName: 表名
    /// - Returns: 表结构
    func getTableSchema(tableName: String) -> [String: String]? {
        return mockTables[tableName]
    }
    
    /// 获取表索引
    /// - Parameter tableName: 表名
    /// - Returns: 索引列表
    func getTableIndexes(tableName: String) -> [String]? {
        return mockIndexes[tableName]
    }
    
    // MARK: - 测试辅助方法
    
    /// 重置模拟数据
    func reset() {
        mockData.removeAll()
        mockTables.removeAll()
        mockIndexes.removeAll()
        setupDefaultMockData()
    }
    
    /// 设置模拟数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - data: 数据
    func setMockData(tableName: String, data: [[String: Any]]) {
        mockData[tableName] = data
    }
    
    /// 设置模拟表结构
    /// - Parameters:
    ///   - tableName: 表名
    ///   - schema: 表结构
    func setMockTableSchema(tableName: String, schema: [String: String]) {
        mockTables[tableName] = schema
    }
    
    /// 设置模拟索引
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexes: 索引列表
    func setMockIndexes(tableName: String, indexes: [String]) {
        mockIndexes[tableName] = indexes
    }
    
    // MARK: - Table Management
    /// 检查表是否存在
    /// - Parameter tableName: 表名
    /// - Returns: 是否存在
    func shouldTableExist(_ tableName: String) -> Bool {
        return mockTables.contains(where: { $0.key == tableName })
    }
    
    /// 检查索引是否存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - indexName: 索引名
    /// - Returns: 是否存在
    func shouldIndexExist(_ tableName: String, _ indexName: String) -> Bool {
        return mockIndexes[tableName]?.contains(where: { $0 == indexName }) ?? false
    }
    
    /// 获取表结构
    /// - Parameter tableName: 表名
    /// - Returns: 表结构
    func getTableStructure(_ tableName: String) -> [String: String] {
        return mockTables[tableName] ?? [:]
    }
    
    /// 获取索引定义
    /// - Parameter tableName: 表名
    /// - Returns: 索引定义
    func getIndexDefinitions(_ tableName: String) -> [String: String] {
        return mockIndexes[tableName]?.reduce([:]) { $0.merging($1.reduce([:]) { $0.merging([$1: ""], uniquingKeysWith: { $1 }) }) } ?? [:]
    }
    
    /// 获取子表结构
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    /// - Returns: 子表结构
    func getSubTableStructure(_ parentTable: String, _ subTable: String) -> [String: String] {
        return mockTables["\(parentTable)_\(subTable)"] ?? [:]
    }
    
    /// 获取表定义
    /// - Parameter tableName: 表名
    /// - Returns: 表定义
    func getTableDefinition(_ tableName: String) -> [String: Any] {
        return mockData[tableName] as? [String: Any] ?? [:]
    }
    
    // MARK: - Response Management
    /// 恢复最近一次响应数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    /// - Returns: 最近一次响应数据
    func restoreLastResponse(api: String, method: String) -> [String: Any]? {
        let tableName = "\(api)_\(method)"
        return mockData[tableName] as? [String: Any]
    }
    
    /// 恢复子表响应数据
    /// - Parameters:
    ///   - api: 接口字符串
    ///   - method: 方法字符串
    ///   - property: 属性名
    /// - Returns: 子表响应数据
    func restoreSubTableResponse(api: String, method: String, property: String) -> [[String: Any]] {
        let tableName = "\(api)_\(method)_\(property)"
        return mockData[tableName] as? [[String: Any]] ?? []
    }
    
    // MARK: - List Properties
    /// 处理列表属性
    /// - Parameters:
    ///   - tableName: 表名
    ///   - listProperties: 列表属性配置
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否成功
    func handleListProperties(tableName: String, listProperties: [String: [String: String]], dbService: CuttDBService) -> Bool {
        for (property, config) in listProperties {
            let subTableName = "\(tableName)_\(property)"
            if !dbService.createSubTable(parentTable: tableName, subTable: subTableName, columns: config) {
                return false
            }
        }
        return true
    }
    
    /// 处理列表关系
    /// - Parameters:
    ///   - tableName: 表名
    ///   - relationships: 关系配置
    ///   - dbService: 数据库服务实例
    /// - Returns: 是否成功
    func handleListRelationships(tableName: String, relationships: [String: String], dbService: CuttDBService) -> Bool {
        for (property, foreignKey) in relationships {
            let subTableName = "\(tableName)_\(property)"
            if !dbService.createIndexIfNeeded(tableName: subTableName, indexName: "fk_\(foreignKey)", columns: [foreignKey]) {
                return false
            }
        }
        return true
    }
} 