import Foundation

/// CuttDBService - 数据库服务接口
/// 提供最基础的数据库操作能力
public protocol CuttDBService {
    // MARK: - 基础操作
    
    /// 执行查询SQL
    /// - Parameters:
    ///   - sql: SQL语句
    ///   - parameters: 参数列表
    /// - Returns: 查询结果集
    func query(sql: String, parameters: [Any]?) -> [[String: Any]]
    
    /// 执行更新SQL
    /// - Parameters:
    ///   - sql: SQL语句
    ///   - parameters: 参数列表
    /// - Returns: 影响的行数
    func execute(sql: String, parameters: [Any]?) -> Int
    
    // MARK: - 事务管理
    
    /// 开始事务
    func beginTransaction()
    
    /// 提交事务
    func commit()
    
    /// 回滚事务
    func rollback()
    
    // MARK: - 表结构管理
    
    /// 创建表
    /// - Parameters:
    ///   - name: 表名
    ///   - columns: 列定义，格式为 ["列名": "类型"]
    /// - Returns: 是否创建成功
    func createTable(name: String, columns: [String: String]) -> Bool
    
    /// 删除表
    /// - Parameter name: 表名
    /// - Returns: 是否删除成功
    func dropTable(name: String) -> Bool
    
    /// 检查表是否存在
    /// - Parameter name: 表名
    /// - Returns: 是否存在
    func tableExists(name: String) -> Bool
    
    /// 获取表结构
    /// - Parameter name: 表名
    /// - Returns: 列定义，格式为 ["列名": "类型"]
    func getTableSchema(name: String) -> [String: String]
    
    // MARK: - 测试支持
    
    /// 设置Mock数据
    /// - Parameters:
    ///   - table: 表名
    ///   - data: 数据列表
    func setMockData(for table: String, data: [[String: Any]])
    
    /// 获取Mock数据
    /// - Parameter table: 表名
    /// - Returns: 数据列表
    func getMockData(for table: String) -> [[String: Any]]
}

/// CuttDBService的默认实现
public class DefaultCuttDBService: CuttDBService {
    private let dbPath: String
    private var mockData: [String: [[String: Any]]] = [:]
    
    public init(dbPath: String) {
        self.dbPath = dbPath
    }
    
    // MARK: - 基础操作实现
    
    public func query(sql: String, parameters: [Any]? = nil) -> [[String: Any]] {
        // TODO: 实现SQL查询
        return []
    }
    
    public func execute(sql: String, parameters: [Any]? = nil) -> Int {
        // TODO: 实现SQL执行
        return 0
    }
    
    // MARK: - 事务管理实现
    
    public func beginTransaction() {
        // TODO: 实现事务开始
    }
    
    public func commit() {
        // TODO: 实现事务提交
    }
    
    public func rollback() {
        // TODO: 实现事务回滚
    }
    
    // MARK: - 表结构管理实现
    
    public func createTable(name: String, columns: [String: String]) -> Bool {
        // TODO: 实现表创建
        return false
    }
    
    public func dropTable(name: String) -> Bool {
        // TODO: 实现表删除
        return false
    }
    
    public func tableExists(name: String) -> Bool {
        // TODO: 实现表存在检查
        return false
    }
    
    public func getTableSchema(name: String) -> [String: String] {
        // TODO: 实现获取表结构
        return [:]
    }
    
    // MARK: - 测试支持实现
    
    public func setMockData(for table: String, data: [[String: Any]]) {
        mockData[table] = data
    }
    
    public func getMockData(for table: String) -> [[String: Any]] {
        return mockData[table] ?? []
    }
}

/// CuttDBService工厂类
public class CuttDBServiceFactory {
    private static var instance: CuttDBServiceFactory?
    private var services: [String: CuttDBService] = [:]
    
    private init() {}
    
    public static func shared() -> CuttDBServiceFactory {
        if instance == nil {
            instance = CuttDBServiceFactory()
        }
        return instance!
    }
    
    public func getService(dbPath: String) -> CuttDBService {
        if let service = services[dbPath] {
            return service
        }
        let service = DefaultCuttDBService(dbPath: dbPath)
        services[dbPath] = service
        return service
    }
} 