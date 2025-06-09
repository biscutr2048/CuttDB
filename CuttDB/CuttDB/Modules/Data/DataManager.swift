import Foundation

/// 数据管理器
internal struct DataManager {
    private let service: CuttDBService
    private let insertManager: InsertManager
    private let updateManager: UpdateManager
    private let deleteManager: DeleteManager
    private let batchManager: BatchManager
    
    init(service: CuttDBService) {
        self.service = service
        self.insertManager = InsertManager(service: service)
        self.updateManager = UpdateManager(service: service)
        self.deleteManager = DeleteManager(service: service)
        self.batchManager = BatchManager(service: service)
    }
    
    /// 保存对象
    func save<T: Codable>(_ object: T, to tableName: String) -> Bool {
        if let dict = object as? [String: Any] {
            return insertManager.insertObject(dict, into: tableName)
        }
        return false
    }
    
    /// 更新对象
    func update<T: Codable>(_ object: T, in tableName: String, where condition: String) -> Bool {
        if let dict = object as? [String: Any] {
            return updateManager.updateObject(dict, in: tableName, where: condition)
        }
        return false
    }
    
    /// 删除对象
    func delete(from tableName: String, where condition: String) -> Bool {
        return deleteManager.delete(from: tableName, where: condition)
    }
    
    /// 批量插入
    func batchInsert(_ objects: [[String: Any]], into tableName: String) -> Bool {
        return batchManager.batchInsert(objects, into: tableName)
    }
    
    /// 批量更新
    func batchUpdate(_ objects: [[String: Any]], in tableName: String) -> Bool {
        return batchManager.batchUpdate(objects, in: tableName)
    }
} 