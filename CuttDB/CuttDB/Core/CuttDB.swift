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
        let configuration = CuttDBServiceConfiguration(dbPath: dbPath)
        self.service = CuttDBServiceFactory.shared.createService(configuration: configuration)
        self.tableManager = TableManager(service: service)
        self.dataManager = DataManager(service: service)
        self.queryManager = QueryManager(service: service)
        self.tableDefinitionManager = TableDefinitionManager(service: service)
        self.sqlGenerator = SQLGenerator()
    }
    
    // MARK: - Internal Table Management
    
    internal func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        return tableManager.ensureTableExists(tableName: tableName, columns: columns)
    }
    
    internal func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        return tableManager.ensureSubTableExists(tableName: tableName, property: property, columns: columns)
    }
    
    internal func createTableFromJSON(tableName: String, json: Any) -> Bool {
        guard let definition = json as? [String: Any] else { return false }
        return tableDefinitionManager.createTableDefinition(tableName: tableName, definition: definition)
    }
    
    internal func validateTableStructure(tableName: String, expectedColumns: [String: String]) -> Bool {
        return tableDefinitionManager.validateTableStructure(tableName: tableName, expectedColumns: expectedColumns)
    }
    
    // MARK: - Public Data Operations
    
    /// 保存对象到数据库
    /// - Parameters:
    ///   - object: 要保存的对象
    ///   - tableName: 表名
    /// - Returns: 是否保存成功
    public func saveObject<T: Encodable>(_ object: T, to tableName: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return false
            }
            return dataManager.insert(tableName: tableName, values: dict)
        } catch {
            return false
        }
    }
    
    /// 插入对象到数据库
    /// - Parameters:
    ///   - object: 要插入的对象
    ///   - tableName: 表名
    /// - Returns: 是否插入成功
    public func insertObject<T: Encodable>(_ object: T, to tableName: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return false
            }
            return dataManager.insert(tableName: tableName, values: dict)
        } catch {
            return false
        }
    }
    
    /// 更新数据库中的对象
    /// - Parameters:
    ///   - object: 要更新的对象
    ///   - tableName: 表名
    ///   - id: 对象ID
    /// - Returns: 是否更新成功
    public func updateObject<T: Encodable>(_ object: T, in tableName: String, id: String) -> Bool {
        do {
            let data = try JSONEncoder().encode(object)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return false
            }
            return dataManager.updateById(tableName: tableName, id: id, values: dict)
        } catch {
            return false
        }
    }
    
    /// 查询数据库中的对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果数组
    public func query<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        return queryManager.query(from: tableName, where: condition, orderBy: orderBy, limit: limit)
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
        return queryManager.pagedQuery(from: tableName, page: page, pageSize: pageSize, where: condition, orderBy: orderBy)
    }
    
    /// 离线查询数据库中的对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果数组
    public func offlineQuery<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        return queryManager.offlineQuery(from: tableName, where: condition, orderBy: orderBy, limit: limit)
    }
    
    // MARK: - Internal Query Operations
    
    internal func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        return queryManager.queryObject(from: tableName, where: whereClause)
    }
    
    internal func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        return queryManager.queryList(from: tableName, where: whereClause, orderBy: orderBy, limit: limit)
    }
    
    // MARK: - Request Index Key Generation
    
    internal func generateRequestIndexKey(api: String, method: String) -> String {
        return "\(api)_\(method)"
    }
} 