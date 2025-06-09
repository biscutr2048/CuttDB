import Foundation

/// CuttDBServiceFactory - 负责创建和管理CuttDBService实例
public class CuttDBServiceFactory {
    private static var shared: CuttDBServiceFactory?
    private var services: [String: CuttDBService] = [:]
    private let queue = DispatchQueue(label: "com.cuttdb.factory")
    
    private init() {}
    
    /// 获取单例实例
    public static func shared() -> CuttDBServiceFactory {
        if shared == nil {
            shared = CuttDBServiceFactory()
        }
        return shared!
    }
    
    /// 创建或获取CuttDBService实例
    /// - Parameter dbPath: 数据库路径
    /// - Returns: CuttDBService实例
    public func getService(dbPath: String) -> CuttDBService {
        queue.sync {
            if let service = services[dbPath] {
                return service
            }
            
            let service = DefaultCuttDBService(dbPath: dbPath)
            services[dbPath] = service
            return service
        }
    }
    
    /// 关闭指定数据库连接
    /// - Parameter dbPath: 数据库路径
    public func closeService(dbPath: String) {
        queue.sync {
            services.removeValue(forKey: dbPath)
        }
    }
    
    /// 关闭所有数据库连接
    public func closeAllServices() {
        queue.sync {
            services.removeAll()
        }
    }
} 