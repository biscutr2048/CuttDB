import Foundation

/// 查询管理器
internal struct QueryManager {
    private let service: CuttDBService
    private let objectQuery: ObjectQuery
    private let listQuery: ListQuery
    private let pagedQuery: PagedQuery
    private let offlineQuery: OfflineQuery
    
    init(service: CuttDBService) {
        self.service = service
        self.objectQuery = ObjectQuery(service: service)
        self.listQuery = ListQuery(service: service)
        self.pagedQuery = PagedQuery(service: service)
        self.offlineQuery = OfflineQuery(service: service)
    }
    
    /// 查询对象
    func query<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        let results = listQuery.queryList(from: tableName, where: condition, orderBy: orderBy, limit: limit)
        return results.compactMap { dict in
            try? JSONSerialization.data(withJSONObject: dict)
                .flatMap { try? JSONDecoder().decode(T.self, from: $0) }
        }
    }
    
    /// 分页查询
    func pagedQuery<T: Codable>(from tableName: String, page: Int, pageSize: Int, where condition: String? = nil, orderBy: String? = nil) -> [T] {
        let results = pagedQuery.queryPaged(from: tableName, page: page, pageSize: pageSize, where: condition, orderBy: orderBy)
        return results.compactMap { dict in
            try? JSONSerialization.data(withJSONObject: dict)
                .flatMap { try? JSONDecoder().decode(T.self, from: $0) }
        }
    }
    
    /// 离线查询
    func offlineQuery<T: Codable>(from tableName: String, where condition: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [T] {
        let results = offlineQuery.queryOffline(from: tableName, where: condition, orderBy: orderBy, limit: limit)
        return results.compactMap { dict in
            try? JSONSerialization.data(withJSONObject: dict)
                .flatMap { try? JSONDecoder().decode(T.self, from: $0) }
        }
    }
    
    /// 查询单个对象
    func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        return objectQuery.queryObject(from: tableName, where: whereClause)
    }
    
    /// 查询列表
    func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        return listQuery.queryList(from: tableName, where: whereClause, orderBy: orderBy, limit: limit)
    }
    
    /// 查询数量
    func queryCount(from tableName: String, where whereClause: String? = nil) -> Int {
        let sql = SQLGenerator.generateCountSQL(tableName: tableName, whereClause: whereClause)
        let result = service.query(sql)
        return result.first?["count"] as? Int ?? 0
    }
} 