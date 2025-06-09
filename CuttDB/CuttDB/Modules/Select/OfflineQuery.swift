import Foundation

/// 离线查询管理器 - 负责离线数据查询操作
public struct OfflineQuery {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 从缓存恢复响应数据
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    /// - Returns: 缓存的响应数据
    public func restoreResponse(api: String, method: String) -> [String: Any]? {
        let key = StringUtils.requestIndexKey(api: api, method: method)
        return service.getCache(key: key)
    }
    
    /// 从缓存恢复子表响应数据
    /// - Parameters:
    ///   - parentTable: 父表名
    ///   - subTable: 子表名
    ///   - parentId: 父表ID
    /// - Returns: 子表数据列表
    public func restoreSubTableResponse(parentTable: String, subTable: String, parentId: String) -> [[String: Any]] {
        let whereClause = "\(parentTable)_id = '\(parentId)'"
        let sql = "SELECT * FROM \(subTable) WHERE \(whereClause)"
        return service.query(sql)
    }
    
    /// 保存响应数据到缓存
    /// - Parameters:
    ///   - api: API路径
    ///   - method: 请求方法
    ///   - data: 响应数据
    ///   - expiration: 过期时间（秒）
    public func saveResponse(api: String, method: String, data: [String: Any], expiration: TimeInterval = 3600) {
        let key = StringUtils.requestIndexKey(api: api, method: method)
        service.setCache(key: key, value: data, expiration: expiration)
    }
    
    /// 清理过期的缓存数据
    public func cleanupExpiredCache() {
        service.cleanupExpiredCache()
    }
} 