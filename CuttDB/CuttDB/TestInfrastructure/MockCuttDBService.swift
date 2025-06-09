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
} 