import Foundation

/// CuttDB - 一个轻量级的数据库管理系统
public struct CuttDB {
    // MARK: - Properties
    private let service: CuttDBService
    private let dbPath: String
    private let tableManager: TableManager
    private let dataManager: DataManager
    private let queryManager: QueryManager
    private let tableDefinitionManager: TableDefinitionManager
    private let sqlGenerator: SQLGenerator
    
    // MARK: - Initialization
    public init(dbName: String = "cuttDB.sqlite") {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.dbPath = documentsPath.appendingPathComponent(dbName).path
        self.service = CuttDBServiceFactory.shared().getService(dbPath: dbPath)
        self.tableManager = TableManager(service: service)
        self.dataManager = DataManager(service: service)
        self.queryManager = QueryManager(service: service)
        self.tableDefinitionManager = TableDefinitionManager(service: service)
        self.sqlGenerator = SQLGenerator()
    }
    
    // MARK: - Internal Table Management
    
    internal func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        tableManager.ensureTableExists(tableName: tableName, columns: columns)
    }
    
    internal func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        tableManager.ensureSubTableExists(tableName: tableName, property: property, columns: columns)
    }
    
    internal func createTableFromJSON(tableName: String, json: Any) -> Bool {
        tableDefinitionManager.createTableDefinition(tableName: tableName, definition: json)
    }
    
    internal func validateTableStructure(tableName: String, expectedColumns: [String: String]) -> Bool {
        tableDefinitionManager.validateTableStructure(tableName: tableName, expectedColumns: expectedColumns)
    }
    
    // MARK: - Public Data Operations
    
    /// 保存对象到数据库
    /// - Parameters:
    ///   - object: 要保存的对象
    ///   - tableName: 表名
    /// - Returns: 是否保存成功
    public func save<T: Codable>(_ object: T, to tableName: String) -> Bool {
        dataManager.save(object, to: tableName)
    }
    
    /// 更新数据库中的对象
    /// - Parameters:
    ///   - object: 要更新的对象
    ///   - tableName: 表名
    ///   - condition: 更新条件
    /// - Returns: 是否更新成功
    public func update<T: Codable>(_ object: T, in tableName: String, where condition: String) -> Bool {
        dataManager.update(object, in: tableName, where: condition)
    }
    
    /// 从数据库中删除对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 删除条件
    /// - Returns: 是否删除成功
    public func delete(from tableName: String, where condition: String) -> Bool {
        dataManager.delete(from: tableName, where: condition)
    }
    
    // MARK: - Internal Data Operations
    
    internal func saveObject(_ object: [String: Any], to tableName: String) -> Bool {
        dataManager.saveObject(object, to: tableName)
    }
    
    internal func insertObject(_ object: [String: Any], into tableName: String) -> Bool {
        dataManager.insertObject(object, into: tableName)
    }
    
    internal func updateObject(_ object: [String: Any], in tableName: String) -> Bool {
        dataManager.updateObject(object, in: tableName)
    }
    
    internal func batchInsert(_ objects: [[String: Any]], into tableName: String) -> Bool {
        dataManager.batchInsert(objects, into: tableName)
    }
    
    internal func batchUpdate(_ objects: [[String: Any]], in tableName: String) -> Bool {
        dataManager.batchUpdate(objects, in: tableName)
    }
    
    // MARK: - Public Query Operations
    
    /// 查询数据库中的对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果数组
    public func query<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        queryManager.query(from: tableName, where: condition, orderBy: orderBy, limit: limit)
    }
    
    /// 分页查询数据库中的对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - page: 页码
    ///   - pageSize: 每页数量
    ///   - condition: 查询条件
    ///   - orderBy: 排序条件
    /// - Returns: 查询结果数组
    public func pagedQuery<T: Codable>(from tableName: String, page: Int, pageSize: Int, where condition: String? = nil, orderBy: String? = nil) -> [T] {
        queryManager.pagedQuery(from: tableName, page: page, pageSize: pageSize, where: condition, orderBy: orderBy)
    }
    
    /// 离线查询数据库中的对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果数组
    public func offlineQuery<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        queryManager.offlineQuery(from: tableName, where: condition, orderBy: orderBy, limit: limit)
    }
    
    // MARK: - Internal Query Operations
    
    internal func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        queryManager.queryObject(from: tableName, where: whereClause)
    }
    
    internal func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        queryManager.queryList(from: tableName, where: whereClause, orderBy: orderBy, limit: limit)
    }
    
    internal func queryCount(from tableName: String, where whereClause: String? = nil) -> Int {
        queryManager.queryCount(from: tableName, where: whereClause)
    }
    
    // MARK: - Utility Methods
    
    /// 生成请求索引键
    /// - Parameters:
    ///   - tableName: 表名
    ///   - property: 属性名
    ///   - value: 属性值
    /// - Returns: 索引键
    public func generateRequestIndexKey(tableName: String, property: String, value: Any) -> String {
        sqlGenerator.generateRequestIndexKey(tableName: tableName, property: property, value: value)
    }
    
    internal static func requestIndexKey(api: String, method: String) -> String {
        StringUtils.requestIndexKey(api: api, method: method)
    }
} 