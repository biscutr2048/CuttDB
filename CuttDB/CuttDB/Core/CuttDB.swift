import Foundation

/// CuttDB - 核心接口
/// 提供简化的、高度自动化的API给用户代码
public struct CuttDB {
    private let service: CuttDBService
    private let dbPath: String
    
    /// 初始化CuttDB实例
    /// - Parameter dbName: 数据库名称，默认为"cuttDB.sqlite"
    public init(dbName: String = "cuttDB.sqlite") {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.dbPath = documentsPath.appendingPathComponent(dbName).path
        self.service = CuttDBServiceFactory.shared().getService(dbPath: dbPath)
    }
    
    // MARK: - 表管理
    
    /// 确保表存在
    /// - Parameters:
    ///   - tableName: 表名
    ///   - columns: 列定义
    /// - Returns: 是否成功
    public func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        TableManager(service: service).ensureTableExists(tableName: tableName, columns: columns)
    }
    
    /// 确保子表存在
    /// - Parameters:
    ///   - tableName: 主表名
    ///   - property: 属性名
    ///   - columns: 列定义
    /// - Returns: 是否成功
    public func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        TableManager(service: service).ensureSubTableExists(tableName: tableName, property: property, columns: columns)
    }
    
    // MARK: - 数据操作
    
    /// 保存对象
    /// - Parameters:
    ///   - object: 要保存的对象
    ///   - tableName: 表名
    /// - Returns: 是否成功
    public func saveObject(_ object: [String: Any], to tableName: String) -> Bool {
        DataManager(service: service).saveObject(object, to: tableName)
    }
    
    /// 插入对象
    /// - Parameters:
    ///   - object: 要插入的对象
    ///   - tableName: 表名
    /// - Returns: 是否成功
    public func insertObject(_ object: [String: Any], into tableName: String) -> Bool {
        DataManager(service: service).insertObject(object, into: tableName)
    }
    
    /// 更新对象
    /// - Parameters:
    ///   - object: 要更新的对象
    ///   - tableName: 表名
    /// - Returns: 是否成功
    public func updateObject(_ object: [String: Any], in tableName: String) -> Bool {
        DataManager(service: service).updateObject(object, in: tableName)
    }
    
    /// 查询对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    /// - Returns: 查询结果
    public func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        QueryManager(service: service).queryObject(from: tableName, where: whereClause)
    }
    
    /// 查询列表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果
    public func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        QueryManager(service: service).queryList(from: tableName, where: whereClause, orderBy: orderBy, limit: limit)
    }
    
    // MARK: - 工具方法
    
    /// 生成请求索引键
    /// - Parameters:
    ///   - api: API路径
    ///   - method: HTTP方法
    /// - Returns: 索引键
    public static func requestIndexKey(api: String, method: String) -> String {
        StringUtils.requestIndexKey(api: api, method: method)
    }
} 