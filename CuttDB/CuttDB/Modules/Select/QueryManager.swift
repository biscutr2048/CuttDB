import Foundation

/// 查询管理模块
struct QueryManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 查询对象
    func queryObject(from tableName: String, where whereClause: String) -> [String: Any]? {
        let sql = SQLGenerator.generateSelectSQL(
            tableName: tableName,
            whereClause: whereClause,
            limit: 1
        )
        return service.query(sql: sql)?.first
    }
    
    /// 查询列表
    func queryList(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        let sql = SQLGenerator.generateSelectSQL(
            tableName: tableName,
            whereClause: whereClause,
            orderBy: orderBy,
            limit: limit
        )
        return service.query(sql: sql) ?? []
    }
    
    /// 分页查询
    func queryPaged(from tableName: String, page: Int, pageSize: Int, where whereClause: String? = nil, orderBy: String? = nil) -> [[String: Any]] {
        let offset = (page - 1) * pageSize
        let sql = SQLGenerator.generateSelectSQL(
            tableName: tableName,
            whereClause: whereClause,
            orderBy: orderBy,
            limit: pageSize,
            offset: offset
        )
        return service.query(sql: sql) ?? []
    }
    
    /// 查询总数
    func queryCount(from tableName: String, where whereClause: String? = nil) -> Int {
        let sql = SQLGenerator.generateCountSQL(
            tableName: tableName,
            whereClause: whereClause
        )
        return service.query(sql: sql)?.first?["count"] as? Int ?? 0
    }
} 