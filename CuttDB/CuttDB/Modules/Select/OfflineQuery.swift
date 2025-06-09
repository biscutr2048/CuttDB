import Foundation

/// 离线查询管理器 - 负责离线数据查询
internal struct OfflineQuery {
    private let service: CuttDBService
    private let cacheManager: CacheManager
    
    init(service: CuttDBService) {
        self.service = service
        self.cacheManager = CacheManager(service: service)
    }
    
    /// 执行离线查询
    /// - Parameters:
    ///   - tableName: 表名
    ///   - whereClause: WHERE 子句
    ///   - orderBy: 排序字段
    ///   - limit: 限制数量
    /// - Returns: 查询结果
    func queryOffline(from tableName: String, where whereClause: String? = nil, orderBy: String? = nil, limit: Int? = nil) -> [[String: Any]] {
        // 生成缓存键
        let cacheKey = generateCacheKey(tableName: tableName, whereClause: whereClause, orderBy: orderBy, limit: limit)
        
        // 尝试从缓存获取数据
        if let cachedData = cacheManager.getCache(key: cacheKey) {
            return cachedData
        }
        
        // 构建查询SQL
        var sql = "SELECT * FROM \(tableName)"
        if let whereClause = whereClause {
            sql += " WHERE \(whereClause)"
        }
        if let orderBy = orderBy {
            sql += " ORDER BY \(orderBy)"
        }
        if let limit = limit {
            sql += " LIMIT \(limit)"
        }
        
        // 执行查询
        let results = service.query(sql: sql, parameters: nil)
        
        // 缓存结果
        cacheManager.setCache(key: cacheKey, value: results)
        
        return results
    }
    
    /// 清理过期缓存
    func cleanupExpiredCache() {
        cacheManager.cleanupExpiredCache()
    }
    
    /// 生成缓存键
    private func generateCacheKey(tableName: String, whereClause: String?, orderBy: String?, limit: Int?) -> String {
        var components = [tableName]
        if let whereClause = whereClause {
            components.append(whereClause)
        }
        if let orderBy = orderBy {
            components.append(orderBy)
        }
        if let limit = limit {
            components.append("\(limit)")
        }
        return components.joined(separator: "_")
    }
}

/// 缓存管理器
private struct CacheManager {
    private let service: CuttDBService
    private let cacheTable = "query_cache"
    private let cacheExpiration: TimeInterval = 3600 // 1小时
    
    init(service: CuttDBService) {
        self.service = service
        ensureCacheTableExists()
    }
    
    /// 获取缓存
    func getCache(key: String) -> [[String: Any]]? {
        let sql = "SELECT data FROM \(cacheTable) WHERE cache_key = ? AND created_at > ?"
        let expirationTime = Date().timeIntervalSince1970 - cacheExpiration
        let result = service.query(sql: sql, parameters: [key, expirationTime])
        
        guard let data = result.first?["data"] as? String,
              let jsonData = data.data(using: .utf8),
              let cachedData = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
            return nil
        }
        
        return cachedData
    }
    
    /// 设置缓存
    func setCache(key: String, value: [[String: Any]]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: value),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return
        }
        
        let sql = """
            INSERT OR REPLACE INTO \(cacheTable) (cache_key, data, created_at)
            VALUES (?, ?, ?)
        """
        service.execute(sql: sql, parameters: [key, jsonString, Date().timeIntervalSince1970])
    }
    
    /// 清理过期缓存
    func cleanupExpiredCache() {
        let expirationTime = Date().timeIntervalSince1970 - cacheExpiration
        let sql = "DELETE FROM \(cacheTable) WHERE created_at <= ?"
        service.execute(sql: sql, parameters: [expirationTime])
    }
    
    /// 确保缓存表存在
    private func ensureCacheTableExists() {
        let sql = """
            CREATE TABLE IF NOT EXISTS \(cacheTable) (
                cache_key TEXT PRIMARY KEY,
                data TEXT NOT NULL,
                created_at REAL NOT NULL
            )
        """
        service.execute(sql: sql, parameters: nil)
    }
} 