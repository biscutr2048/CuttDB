import Foundation

/// 模拟数据库服务，用于测试
class MockCuttDBService: CuttDBService {
    var shouldKeyExist = false
    
    override func primaryKeyExists(tableName: String, primaryKey: String, value: Any) -> Bool {
        return shouldKeyExist
    }
} 