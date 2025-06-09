import Foundation

/// CuttDB服务工厂 - 负责创建和管理CuttDB服务实例
public final class CuttDBServiceFactory {
    /// 共享实例
    public static let shared = CuttDBServiceFactory()
    
    private init() {}
    
    /// 创建CuttDB服务实例
    /// - Parameter configuration: 服务配置
    /// - Returns: CuttDB服务实例
    public func createService(configuration: CuttDBServiceConfiguration) -> CuttDBService {
        return DefaultCuttDBService(configuration: configuration)
    }
} 