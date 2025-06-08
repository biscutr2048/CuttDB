//
//  CuttDBTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

#if DEBUG
// MARK: - Create Module Tests
/// 模块：create
/// 需求：auto.get create sql
/// 功能：测试从 JSON 结构提取表格定义
func testExtractTableDefinition() {
    // Test case: Complex JSON structure
    let json: [String: Any] = [
        "id": 123,
        "name": "Alice",
        "profile": [
            "age": 30,
            "city": "Beijing",
            "contact": [
                "email": "alice@example.com",
                "phone": "123456"
            ]
        ],
        "tags": ["swift", "macos"],
        "meta": NSNull(),
        "history": [
            [
                "date": "2024-06-01",
                "action": "login"
            ],
            [
                "date": "2024-06-02",
                "action": "logout"
            ]
        ]
    ]
    
    let def = CuttDB.extractTableDefinition(from: json)
    print("Table Definition:", def)
    // Expected output: [("id", "TEXT"), ("name", "TEXT"), ("profile", "TEXT"), ("tags", "TEXT"), ("meta", "TEXT"), ("history", "TEXT")]
}

// MARK: - Insert/Update Module Tests
/// 模块：insert/update
/// 需求：op.save object to insert sql, op.save object to update sql
/// 功能：测试生成 SQL 语句
func testGenerateSQL() {
    // Create a mock CuttDBService
    let mockDBService = MockCuttDBService()
    
    // Test case 1: Insert new record
    let insertJson: [String: Any] = [
        "id": 1,
        "name": "Test User",
        "email": "test@example.com"
    ]
    
    let insertSQL = CuttDB.generateSQL(api: "/user", method: "POST", json: insertJson, dbService: mockDBService)
    print("Test 1 - Insert SQL:", insertSQL ?? "nil")
    
    // Test case 2: Update existing record
    mockDBService.shouldKeyExist = true
    let updateSQL = CuttDB.generateSQL(api: "/user", method: "PUT", json: insertJson, dbService: mockDBService)
    print("Test 2 - Update SQL:", updateSQL ?? "nil")
}

// MARK: - List Properties Module Tests
/// 模块：create
/// 需求：auto.create sub-table when listing
/// 功能：测试处理列表属性
func testHandleListProperties() {
    // Create a mock CuttDBService
    let mockDBService = MockCuttDBService()
    
    // Test case: JSON with list properties
    let json: [String: Any] = [
        "id": 1,
        "name": "Test User",
        "orders": [
            ["id": 101, "product": "Item 1"],
            ["id": 102, "product": "Item 2"]
        ]
    ]
    
    let result = CuttDB.handleListProperties(api: "/user", method: "GET", json: json, dbService: mockDBService)
    print("List Properties Result:", result)
}

// MARK: - Mechanism Module Tests
/// 模块：mechanism
/// 需求：pair table to req, obj_list, paged
/// 功能：测试请求索引词生成
func testRequestIndexKey() {
    // Test case 1: Basic API path with GET method
    let key1 = CuttDB.requestIndexKey(api: "/user/list", method: "GET")
    print("Test 1 - Basic API path:", key1) // Expected: userlist_GET
    
    // Test case 2: API path with hyphens and lowercase method
    let key2 = CuttDB.requestIndexKey(api: "order-detail", method: "post")
    print("Test 2 - Hyphenated path:", key2) // Expected: orderdetail_post
    
    // Test case 3: API path with special characters
    let key3 = CuttDB.requestIndexKey(api: "user/profile/123", method: "PUT")
    print("Test 3 - Special characters:", key3) // Expected: userprofile123_PUT
}

// MARK: - Mock CuttDBService
/// 模块：mechanism
/// 需求：pair table to req, obj_list, paged
/// 功能：模拟数据库服务，用于测试
class MockCuttDBService: CuttDBService {
    var shouldKeyExist = false
    
    override func primaryKeyExists(tableName: String, primaryKey: String, value: Any) -> Bool {
        return shouldKeyExist
    }
}

// MARK: - Run All Tests
/// 运行所有测试用例
func runAllTests() {
    print("\n=== Running CuttDB Tests ===\n")
    
    print("Testing Create Module...")
    testExtractTableDefinition()
    
    print("\nTesting Insert/Update Module...")
    testGenerateSQL()
    
    print("\nTesting List Properties Module...")
    testHandleListProperties()
    
    print("\nTesting Mechanism Module...")
    testRequestIndexKey()
    
    print("\n=== All Tests Completed ===\n")
}
#endif 