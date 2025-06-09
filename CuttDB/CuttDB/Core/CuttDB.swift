import Foundation

/// CuttDB - 用户接口层
/// 提供简化的、高度自动化的API给用户代码
public struct CuttDB {
    private let service: CuttDBService
    private let dbPath: String
    private let tableManager: TableManager
    private let dataManager: DataManager
    private let queryManager: QueryManager
    private let tableDefinitionManager: TableDefinitionManager

    /// 初始化CuttDB实例
    public init(dbName: String = "cuttDB.sqlite") {
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.dbPath = documentsPath.appendingPathComponent(dbName).path
        self.service = CuttDBServiceFactory.shared().getService(dbPath: dbPath)
        self.tableManager = TableManager(service: service)
        self.dataManager = DataManager(service: service)
        self.queryManager = QueryManager(service: service)
        self.tableDefinitionManager = TableDefinitionManager(service: service)
    }

    // MARK: - 表管理

    public func ensureTableExists(tableName: String, columns: [String]) -> Bool {
        tableManager.ensureTableExists(tableName: tableName, columns: columns)
    }

    public func ensureSubTableExists(tableName: String, property: String, columns: [String]) -> Bool {
        tableManager.ensureSubTableExists(tableName: tableName, property: property, columns: columns)
    }

    public func createTableFromJSON(tableName: String, json: Any) -> Bool {
        tableDefinitionManager.createTableDefinition(tableName: tableName, definition: json)
    }

    public func validateTableStructure(tableName: String, expectedColumns: [String: String]) -> Bool {
        tableDefinitionManager.validateTableStructure(tableName: tableName, expectedColumns: expectedColumns)
    }

    // MARK: - 数据操作

    public func saveObject(_ object: [String: Any], to tableName: String) -> Bool {
        dataManager.saveObject(object, to: tableName)
    }

    public func insertObject(_ object: [String: Any], into tableName: String) -> Bool {
        dataManager.insertObject(object, into: tableName)
    }

    public func updateObject(_ object: [String: Any], in tableName: String) -> Bool {
        dataManager.updateObject(object, in: tableName)
    }

    public func batchInsert(_ objects: [[String: Any]], into tableName: String) -> Bool {
        dataManager.batchInsert(objects, into: tableName)
    }

    public func batchUpdate(_ objects: [[String: Any]], in tableName: String) -> Bool {
        dataManager.batchUpdate(objects, in: tableName)
    }

    // MARK: - 查询操作

    public func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        queryManager.queryObject(from: tableName, where: whereClause)
    }

    public func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        queryManager.queryList(from: tableName, where: whereClause, orderBy: orderBy, limit: limit)
    }

    public func queryPaged(from tableName: String, page: Int, pageSize: Int, where whereClause: String? = nil, orderBy: String? = nil) -> [[String: Any]] {
        queryManager.queryPaged(from: tableName, page: page, pageSize: pageSize, where: whereClause, orderBy: orderBy)
    }

    public func queryCount(from tableName: String, where whereClause: String? = nil) -> Int {
        queryManager.queryCount(from: tableName, where: whereClause)
    }

    // MARK: - 工具方法

    public static func requestIndexKey(api: String, method: String) -> String {
        StringUtils.requestIndexKey(api: api, method: method)
    }
} 