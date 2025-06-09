import Foundation

/// 向量管理器 - 负责向量数据的存储和检索
internal struct VectorManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 存储向量数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 向量ID
    ///   - vector: 向量数据
    /// - Returns: 是否存储成功
    func storeVector(tableName: String, id: String, vector: [Float]) -> Bool {
        let vectorData = vector.map { String($0) }.joined(separator: ",")
        let sql = "INSERT INTO \(tableName) (id, vector) VALUES ('\(id)', '\(vectorData)')"
        return service.execute(sql: sql, parameters: nil) > 0
    }
    
    /// 检索相似向量
    /// - Parameters:
    ///   - tableName: 表名
    ///   - vector: 查询向量
    ///   - limit: 返回结果数量限制
    /// - Returns: 相似向量ID列表
    func searchSimilarVectors(tableName: String, vector: [Float], limit: Int = 10) -> [String] {
        let vectorData = vector.map { String($0) }.joined(separator: ",")
        let sql = """
            SELECT id, vector
            FROM \(tableName)
            ORDER BY cosine_similarity(vector, '\(vectorData)') DESC
            LIMIT \(limit)
        """
        
        let results = service.query(sql: sql, parameters: nil)
        return results.compactMap { $0["id"] as? String }
    }
    
    /// 计算余弦相似度
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        guard a.count == b.count else { return 0 }
        
        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0
        
        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }
        
        guard normA > 0 && normB > 0 else { return 0 }
        return dotProduct / (sqrt(normA) * sqrt(normB))
    }
} 