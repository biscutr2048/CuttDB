import Foundation

/// 数据管理模块
struct DataManager {
    private let service: CuttDBService
    
    init(service: CuttDBService) {
        self.service = service
    }
    
    /// 保存对象
    func saveObject(_ object: [String: Any], to tableName: String) -> Bool {
        if let id = object["id"] as? Int {
            return updateObject(object, in: tableName)
        } else {
            return insertObject(object, into: tableName)
        }
    }
    
    /// 插入对象
    func insertObject(_ object: [String: Any], into tableName: String) -> Bool {
        let sql = SQLGenerator.generateInsertSQL(tableName: tableName, values: object)
        return service.execute(sql: sql)
    }
    
    /// 更新对象
    func updateObject(_ object: [String: Any], in tableName: String) -> Bool {
        guard let id = object["id"] as? Int else { return false }
        let sql = SQLGenerator.generateUpdateSQL(tableName: tableName, values: object, whereClause: "id = \(id)")
        return service.execute(sql: sql)
    }
    
    /// 批量插入对象
    func batchInsert(_ objects: [[String: Any]], into tableName: String) -> Bool {
        service.beginTransaction()
        defer {
            if !objects.isEmpty {
                service.commitTransaction()
            } else {
                service.rollbackTransaction()
            }
        }
        
        for object in objects {
            if !insertObject(object, into: tableName) {
                return false
            }
        }
        return true
    }
    
    /// 批量更新对象
    func batchUpdate(_ objects: [[String: Any]], in tableName: String) -> Bool {
        service.beginTransaction()
        defer {
            if !objects.isEmpty {
                service.commitTransaction()
            } else {
                service.rollbackTransaction()
            }
        }
        
        for object in objects {
            if !updateObject(object, in: tableName) {
                return false
            }
        }
        return true
    }
} 