# 测试基础设施

本目录包含用于测试的基础设施代码。

## MockCuttDBService

`MockCuttDBService` 是一个模拟数据库服务类，用于在测试环境中模拟数据库操作。它提供了以下功能：

### 主要特性

1. **模拟数据操作**
   - 执行SQL查询
   - 执行SQL更新
   - 获取表结构
   - 获取表索引

2. **测试配置**
   - 模拟错误情况
   - 模拟操作延迟
   - 自定义错误消息

3. **数据管理**
   - 设置模拟数据
   - 设置表结构
   - 设置索引
   - 重置模拟数据

### 使用示例

```swift
// 创建模拟服务实例
let mockDBService = MockCuttDBService()

// 配置测试场景
mockDBService.shouldSimulateError = true
mockDBService.simulatedDelay = 100

// 设置模拟数据
mockDBService.setMockData(tableName: "users", data: [
    ["id": 1, "name": "Test User"]
])

// 执行测试
let result = mockDBService.executeQuery(sql: "SELECT * FROM users")
```

### 最佳实践

1. 在每个测试用例开始前重置模拟数据
2. 使用 `setMockData` 设置测试所需的数据
3. 使用 `shouldSimulateError` 测试错误处理
4. 使用 `simulatedDelay` 测试异步操作

## 目录结构

```
TestInfrastructure/
├── README.md
└── MockCuttDBService.swift
``` 