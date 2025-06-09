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
    public init(configuration: CuttDBServiceConfiguration) {
        self.service = CuttDBServiceFactory.shared.createService(configuration: configuration)
        self.dbPath = configuration.dbPath
        self.tableManager = TableManager(service: service)
        self.tableDefinitionManager = TableDefinitionManager(service: service)
        self.queryManager = QueryManager(service: service)
        self.dataManager = DataManager(service: service)
        self.sqlGenerator = SQLGenerator()
    }
    
    // MARK: - Internal Table Management
    
    @discardableResult
    public func ensureTableExists(tableName: String, columns: [String: String]) -> Bool {
        return tableManager.ensureTableExists(tableName: tableName, columns: Array(columns.keys))
    }
    
    @discardableResult
    public func ensureSubTableExists(parentTable: String, subTable: String, columns: [String: String]) -> Bool {
        return tableManager.ensureSubTableExists(tableName: parentTable, property: subTable, columns: Array(columns.keys))
    }
    
    @discardableResult
    public func createTableFromJSON(tableName: String, json: [String: Any]) -> Bool {
        return tableDefinitionManager.createTableDefinition(tableName: tableName, definition: json)
    }
    
    public func validateTableStructure(tableName: String, columns: [String: String]) -> Bool {
        return tableDefinitionManager.validateTableStructure(tableName: tableName, expectedColumns: columns)
    }
    
    // MARK: - Public Data Operations
    
    @discardableResult
    public func saveObject<T: Encodable>(_ object: T) -> Bool {
        guard let tableName = String(describing: type(of: object)).components(separatedBy: ".").last,
              let jsonData = try? JSONEncoder().encode(object),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return false
        }
        if let id = dict["id"] as? String {
            return dataManager.updateById(tableName: tableName, id: id, values: dict)
        } else {
            return dataManager.insert(tableName: tableName, values: dict)
        }
    }
    
    @discardableResult
    public func insertObject<T: Encodable>(_ object: T) -> Bool {
        guard let tableName = String(describing: type(of: object)).components(separatedBy: ".").last,
              let jsonData = try? JSONEncoder().encode(object),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return false
        }
        return dataManager.insert(tableName: tableName, values: dict)
    }
    
    @discardableResult
    public func updateObject<T: Encodable>(_ object: T) -> Bool {
        guard let tableName = String(describing: type(of: object)).components(separatedBy: ".").last,
              let jsonData = try? JSONEncoder().encode(object),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let id = dict["id"] as? String else {
            return false
        }
        return dataManager.updateById(tableName: tableName, id: id, values: dict)
    }
    
    /// 查询数据库中的对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果数组
    public func query<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        let results = queryManager.query(tableName: tableName, columns: ["*"], whereClause: condition, parameters: nil)
        return results.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let object = try? JSONDecoder().decode(T.self, from: jsonData) else {
                return nil
            }
            return object
        }
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
        let results = queryManager.queryWithPagination(tableName: tableName, page: page, pageSize: pageSize, columns: ["*"], whereClause: condition, parameters: nil, orderBy: orderBy)
        return results.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let object = try? JSONDecoder().decode(T.self, from: jsonData) else {
                return nil
            }
            return object
        }
    }
    
    /// 离线查询数据库中的对象
    /// - Parameters:
    ///   - tableName: 表名
    ///   - condition: 查询条件
    ///   - orderBy: 排序条件
    ///   - limit: 限制数量
    /// - Returns: 查询结果数组
    public func offlineQuery<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        let results = queryManager.query(tableName: tableName, columns: ["*"], whereClause: condition, parameters: nil)
        return results.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let object = try? JSONDecoder().decode(T.self, from: jsonData) else {
                return nil
            }
            return object
        }
    }
    
    // MARK: - Internal Query Operations
    
    internal func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        return queryManager.queryObject(tableName: tableName, id: whereClause)
    }
    
    internal func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        return queryManager.query(tableName: tableName, columns: ["*"], whereClause: whereClause, parameters: nil)
    }
    
    // MARK: - Request Index Key Generation
    
    internal func generateRequestIndexKey(api: String, method: String) -> String {
        return "\(api)_\(method)"
    }
    
    public func queryObjects<T: Decodable>(_ type: T.Type, whereClause: String? = nil, parameters: [Any]? = nil) -> [T] {
        let tableName = String(describing: type).components(separatedBy: ".").last ?? ""
        let results = queryManager.query(tableName: tableName, columns: ["*"], whereClause: whereClause, parameters: parameters)
        return results.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let object = try? JSONDecoder().decode(T.self, from: jsonData) else {
                return nil
            }
            return object
        }
    }
    
    public func queryWithPagination<T: Decodable>(_ type: T.Type, page: Int, pageSize: Int, whereClause: String? = nil, parameters: [Any]? = nil, orderBy: String? = nil) -> [T] {
        let tableName = String(describing: type).components(separatedBy: ".").last ?? ""
        let results = queryManager.queryWithPagination(tableName: tableName, page: page, pageSize: pageSize, columns: ["*"], whereClause: whereClause, parameters: parameters, orderBy: orderBy)
        return results.compactMap { dict in
            guard let jsonData = try? JSONSerialization.data(withJSONObject: dict),
                  let object = try? JSONDecoder().decode(T.self, from: jsonData) else {
                return nil
            }
            return object
        }
    }
    
    public func queryObject<T: Decodable>(_ type: T.Type, id: String) -> T? {
        let tableName = String(describing: type).components(separatedBy: ".").last ?? ""
        guard let dict = queryManager.queryObject(tableName: tableName, id: id),
              let jsonData = try? JSONSerialization.data(withJSONObject: dict),
              let object = try? JSONDecoder().decode(T.self, from: jsonData) else {
            return nil
        }
        return object
    }
    
    @discardableResult
    public func deleteObject<T>(_ type: T.Type, id: String) -> Bool {
        let tableName = String(describing: type).components(separatedBy: ".").last ?? ""
        return dataManager.deleteById(tableName: tableName, id: id)
    }
    
    public func getTotalCount<T>(_ type: T.Type, whereClause: String? = nil, parameters: [Any]? = nil) -> Int {
        let tableName = String(describing: type).components(separatedBy: ".").last ?? ""
        return queryManager.getTotalCount(tableName: tableName, whereClause: whereClause, parameters: parameters)
    }
    
    public func exists<T>(_ type: T.Type, whereClause: String, parameters: [Any]? = nil) -> Bool {
        let tableName = String(describing: type).components(separatedBy: ".").last ?? ""
        return queryManager.exists(tableName: tableName, whereClause: whereClause, parameters: parameters)
    }
} 