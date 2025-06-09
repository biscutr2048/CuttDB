import Foundation

/// 创建模块 - 表格定义测试
struct CreateModule_TableDefinitionTest {
    /// 测试数据
    struct Data {
        static let simpleJSON: [String: Any] = [
            "id": 1,
            "name": "Test"
        ]
        
        static let complexJSON: [String: Any] = [
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
        
        static let jsonWithSpecialTypes: [String: Any] = [
            "id": 1,
            "name": "Test",
            "is_active": true,
            "score": 95.5,
            "created_at": "2024-06-09T10:00:00Z",
            "metadata": [
                "version": 1.0,
                "flags": [1, 2, 3]
            ]
        ]
    }
    
    /// 测试逻辑
    struct Logic {
        private let cuttDB: CuttDB
        
        init() {
            self.cuttDB = CuttDB(dbName: "test_table_definition.sqlite")
        }
        
        /// 测试简单JSON结构创建表格
        func testSimpleJSONTableDefinition() {
            let result = cuttDB.createTableFromJSON(tableName: "simple_table", json: Data.simpleJSON)
            print("Simple JSON Table Creation Result:", result)
            assert(result, "Should create table successfully")
            
            let validation = cuttDB.validateTableStructure(
                tableName: "simple_table",
                expectedColumns: ["id": "INTEGER", "name": "TEXT"]
            )
            assert(validation, "Should validate table structure")
        }
        
        /// 测试复杂JSON结构创建表格
        func testComplexJSONTableDefinition() {
            let result = cuttDB.createTableFromJSON(tableName: "complex_table", json: Data.complexJSON)
            print("Complex JSON Table Creation Result:", result)
            assert(result, "Should create table successfully")
            
            let validation = cuttDB.validateTableStructure(
                tableName: "complex_table",
                expectedColumns: [
                    "id": "INTEGER",
                    "name": "TEXT",
                    "profile": "TEXT",
                    "tags": "TEXT",
                    "meta": "TEXT",
                    "history": "TEXT"
                ]
            )
            assert(validation, "Should validate table structure")
        }
        
        /// 测试特殊类型JSON结构创建表格
        func testSpecialTypesTableDefinition() {
            let result = cuttDB.createTableFromJSON(tableName: "special_types_table", json: Data.jsonWithSpecialTypes)
            print("Special Types Table Creation Result:", result)
            assert(result, "Should create table successfully")
            
            let validation = cuttDB.validateTableStructure(
                tableName: "special_types_table",
                expectedColumns: [
                    "id": "INTEGER",
                    "name": "TEXT",
                    "is_active": "INTEGER",
                    "score": "REAL",
                    "created_at": "TEXT",
                    "metadata": "TEXT"
                ]
            )
            assert(validation, "Should validate table structure")
        }
        
        /// 运行所有测试
        func runTests() {
            print("Running Table Definition Tests...")
            testSimpleJSONTableDefinition()
            testComplexJSONTableDefinition()
            testSpecialTypesTableDefinition()
            print("All Table Definition Tests Completed Successfully!")
        }
    }
} 