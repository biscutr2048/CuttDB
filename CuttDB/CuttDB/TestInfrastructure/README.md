# CuttDB Test Infrastructure

本目录包含 CuttDB 的测试基础设施组件，用于支持单元测试和集成测试。

## 测试架构设计

CuttDB 的测试采用分层设计，分为两层：

### 1. 服务层测试 (Service Layer Tests)
- 测试 `CuttDBService` 的具体实现
- 直接使用 `MockCuttDBService` 的方法
- 关注 SQL 生成和执行的正确性
- 验证底层实现

### 2. 接口层测试 (Interface Layer Tests)
- 测试 `CuttDB` 的公共接口
- 通过 `MockCuttDBService` 模拟数据库操作
- 验证接口行为
- 确保接口的正确性和稳定性

## 组件说明

### 1. MockCuttDBService

`MockCuttDBService` 是一个模拟数据库服务，用于在测试环境中模拟数据库操作。

#### 主要特性：
- 数据操作模拟
- 测试配置
- 数据管理

#### 使用示例：
```swift
// 创建实例
let mockService = MockCuttDBService()

// 配置测试行为
mockService.shouldSimulateError = true
mockService.simulatedDelay = 0.5

// 设置模拟数据
mockService.setMockData(for: "users", data: [
    ["id": 1, "name": "Test User"]
])

// 执行查询
let result = mockService.executeQuery("SELECT * FROM users")
```

### 2. CuttDBTest

`CuttDBTest` 是测试控制器，用于组织和执行所有测试用例。

#### 主要特性：
- 模块化测试组织
- 灵活的测试执行
- 详细的测试报告

#### 测试模块：
- Create Module：表定义、子表、自动创建测试
- Select Module：离线查询、分页查询测试
- InsertUpdate Module：SQL生成、事务处理测试
- Delete Module：数据老化、批量删除测试
- Align Module：表结构升级、数据清理测试
- ListProperties Module：复杂列表测试
- Mechanism Module：索引管理、响应处理测试

#### 使用示例：
```swift
// 运行所有测试
CuttDBTest.runAllTests()

// 运行特定模块的测试
CuttDBTest.runTest(for: .create)

// 运行多个模块的测试
CuttDBTest.runTests(for: [.create, .select])

// 运行单个测试用例
CuttDBTest.runTestCase(module: .create, testCase: "testExtractTableDefinition")
```

## 测试文件组织

每个模块的测试文件都遵循以下结构：

```swift
struct ModuleName_TestType {
    struct Data {
        // 测试数据定义
    }
    
    struct ServiceLogic {
        // 服务层测试方法
    }
    
    struct InterfaceLogic {
        // 接口层测试方法
    }
}
```

### 命名规范：
- 服务层测试：`testService*`
- 接口层测试：`testInterface*`

## 最佳实践

1. 测试数据管理
   - 使用 `MockCuttDBService` 管理测试数据
   - 每个测试用例使用独立的测试数据
   - 测试完成后清理测试数据

2. 测试用例组织
   - 按功能模块组织测试用例
   - 使用清晰的命名约定
   - 添加必要的注释说明

3. 测试执行
   - 使用 `CuttDBTest` 控制器执行测试
   - 根据需要选择测试范围
   - 关注测试结果和错误信息

## 目录结构

```
TestInfrastructure/
├── MockCuttDBService.swift    # 模拟数据库服务
├── CuttDBTest.swift          # 测试控制器
└── README.md                 # 说明文档
```

## 注意事项

1. 测试环境
   - 确保测试环境与生产环境隔离
   - 使用模拟服务避免影响实际数据库
   - 注意测试数据的清理

2. 性能考虑
   - 合理设置模拟延迟
   - 避免不必要的数据库操作
   - 优化测试执行时间

3. 维护建议
   - 定期更新测试用例
   - 保持测试代码的可读性
   - 及时处理测试失败

4. 测试分层
   - 保持服务层和接口层测试的独立性
   - 确保两层测试的完整性
   - 避免测试代码的重复 