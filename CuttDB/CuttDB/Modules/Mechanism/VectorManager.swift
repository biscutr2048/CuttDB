import Foundation

/// 向量管理器 - 负责向量数据管理
public struct VectorManager {
    private let service: CuttDBService
    
    public init(service: CuttDBService) {
        self.service = service
    }
    
    /// 创建向量表
    /// - Parameters:
    ///   - tableName: 表名
    ///   - dimension: 向量维度
    /// - Returns: 是否创建成功
    public func createVectorTable(tableName: String, dimension: Int) -> Bool {
        let sql = generateCreateVectorTableSQL(tableName: tableName, dimension: dimension)
        return service.executeSQL(sql)
    }
    
    /// 插入向量数据
    /// - Parameters:
    ///   - tableName: 表名
    ///   - id: 向量ID
    ///   - vector: 向量数据
    /// - Returns: 是否插入成功
    public func insertVector(tableName: String, id: String, vector: [Double]) -> Bool {
        let sql = generateInsertVectorSQL(tableName: tableName, id: id, vector: vector)
        return service.executeSQL(sql)
    }
    
    /// 查询相似向量
    /// - Parameters:
    ///   - tableName: 表名
    ///   - vector: 查询向量
    ///   - limit: 返回结果数量
    /// - Returns: 相似向量列表
    public func querySimilarVectors(tableName: String, vector: [Double], limit: Int = 10) -> [[String: Any]] {
        let sql = generateSimilarVectorsSQL(tableName: tableName, vector: vector, limit: limit)
        return service.query(sql)
    }
    
    /// 生成创建向量表SQL
    private func generateCreateVectorTableSQL(tableName: String, dimension: Int) -> String {
        var columns = ["id TEXT PRIMARY KEY"]
        for i in 0..<dimension {
            columns.append("v\(i) REAL")
        }
        let columnsStr = columns.joined(separator: ", ")
        return "CREATE TABLE IF NOT EXISTS \(tableName) (\(columnsStr))"
    }
    
    /// 生成插入向量SQL
    private func generateInsertVectorSQL(tableName: String, id: String, vector: [Double]) -> String {
        let columns = ["id"] + vector.enumerated().map { "v\($0.offset)" }
        let values = [id] + vector
        let columnsStr = columns.joined(separator: ", ")
        let valuesStr = values.map { value in
            if let stringValue = value as? String {
                return "'\(StringUtils.escapeSQLString(stringValue))'"
            } else {
                return "\(value)"
            }
        }.joined(separator: ", ")
        
        return "INSERT INTO \(tableName) (\(columnsStr)) VALUES (\(valuesStr))"
    }
    
    /// 生成相似向量查询SQL
    private func generateSimilarVectorsSQL(tableName: String, vector: [Double], limit: Int) -> String {
        let dimension = vector.count
        var dotProduct = ""
        var vectorNorm = ""
        var tableNorm = ""
        
        for i in 0..<dimension {
            if i > 0 {
                dotProduct += " + "
                vectorNorm += " + "
                tableNorm += " + "
            }
            dotProduct += "\(vector[i]) * v\(i)"
            vectorNorm += "\(vector[i]) * \(vector[i])"
            tableNorm += "v\(i) * v\(i)"
        }
        
        let similarity = "\(dotProduct) / (SQRT(\(vectorNorm)) * SQRT(\(tableNorm)))"
        
        return """
            SELECT id, \(similarity) as similarity
            FROM \(tableName)
            ORDER BY similarity DESC
            LIMIT \(limit)
            """
    }
} 