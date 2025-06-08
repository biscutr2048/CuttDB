//
//  CuttDBTest.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/6/9.
//

import Foundation

#if DEBUG
// MARK: - Test Cases
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

// MARK: - Mock CuttDBService
class MockCuttDBService: CuttDBService {
    var shouldKeyExist = false
    
    override func primaryKeyExists(tableName: String, primaryKey: String, value: Any) -> Bool {
        return shouldKeyExist
    }
}

// MARK: - Run All Tests
func runAllTests() {
    print("\n=== Running CuttDB Tests ===\n")
    
    print("Testing requestIndexKey...")
    testRequestIndexKey()
    
    print("\nTesting extractTableDefinition...")
    testExtractTableDefinition()
    
    print("\nTesting generateSQL...")
    testGenerateSQL()
    
    print("\nTesting handleListProperties...")
    testHandleListProperties()
    
    print("\n=== All Tests Completed ===\n")
}
#endif 