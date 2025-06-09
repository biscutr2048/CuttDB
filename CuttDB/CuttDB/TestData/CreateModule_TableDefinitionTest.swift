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
        /// 测试简单JSON结构提取表格定义
        static func testSimpleJSONTableDefinition() {
            let def = CuttDB.extractTableDefinition(from: Data.simpleJSON)
            print("Simple JSON Table Definition:", def)
            assert(def.count == 2, "Should extract 2 columns")
        }
        
        /// 测试复杂JSON结构提取表格定义
        static func testComplexJSONTableDefinition() {
            let def = CuttDB.extractTableDefinition(from: Data.complexJSON)
            print("Complex JSON Table Definition:", def)
            assert(def.count > 2, "Should extract more than 2 columns")
        }
        
        /// 测试特殊类型JSON结构提取表格定义
        static func testSpecialTypesTableDefinition() {
            let def = CuttDB.extractTableDefinition(from: Data.jsonWithSpecialTypes)
            print("Special Types Table Definition:", def)
            assert(def.count == 6, "Should extract 6 columns")
        }
        
        /// 测试表格定义类型推断
        static func testTableDefinitionTypeInference() {
            let def = CuttDB.extractTableDefinition(from: Data.jsonWithSpecialTypes)
            let types = def.map { $0.1 }
            print("Inferred Types:", types)
            assert(types.contains("INTEGER"), "Should infer INTEGER type")
            assert(types.contains("TEXT"), "Should infer TEXT type")
            assert(types.contains("REAL"), "Should infer REAL type")
        }
    }
} 