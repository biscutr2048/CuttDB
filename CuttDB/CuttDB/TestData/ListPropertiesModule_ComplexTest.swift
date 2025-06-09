import Foundation

/// 复杂列表属性测试
class ListPropertiesModule_ComplexTest: CuttDBTestCase {
    override func runTests() {
        print("\n=== 复杂列表属性测试 ===")
        
        // 测试数据
        let testData = [
            "complexList": [
                ["id": 1, "name": "Item 1", "value": 100],
                ["id": 2, "name": "Item 2", "value": 200]
            ],
            "nestedList": [
                [
                    "id": 1,
                    "name": "Group 1",
                    "items": [
                        ["id": 1, "name": "Item 1.1"],
                        ["id": 2, "name": "Item 1.2"]
                    ]
                ],
                [
                    "id": 2,
                    "name": "Group 2",
                    "items": [
                        ["id": 3, "name": "Item 2.1"],
                        ["id": 4, "name": "Item 2.2"]
                    ]
                ]
            ]
        ]
        
        // 创建Mock服务
        let mockService = MockCuttDBService()
        
        // 测试复杂列表处理
        print("\n测试复杂列表处理")
        let complexListResult = CuttDB.handleComplexListProperties(
            tableName: "test_table",
            data: testData["complexList"] as! [[String: Any]],
            dbService: mockService
        )
        assert(complexListResult, "复杂列表处理失败")
        
        // 验证复杂列表数据
        let complexListData = mockService.select(tableName: "test_table_complexList")
        assert(complexListData.count == 2, "复杂列表数据验证失败")
        
        // 测试嵌套列表处理
        print("\n测试嵌套列表处理")
        let nestedListResult = CuttDB.handleNestedListProperties(
            tableName: "test_table",
            data: testData["nestedList"] as! [[String: Any]],
            dbService: mockService
        )
        assert(nestedListResult, "嵌套列表处理失败")
        
        // 验证嵌套列表数据
        let nestedListData = mockService.select(tableName: "test_table_nestedList")
        assert(nestedListData.count == 2, "嵌套列表数据验证失败")
        
        // 测试列表表创建
        print("\n测试列表表创建")
        let listConfig = [
            "complexList": ["id": "INTEGER", "name": "TEXT", "value": "INTEGER"],
            "nestedList": ["id": "INTEGER", "name": "TEXT"]
        ]
        let createResult = CuttDB.createListTables(
            tableName: "test_table",
            listProperties: listConfig,
            dbService: mockService
        )
        assert(createResult, "列表表创建失败")
        
        // 测试列表数据验证
        print("\n测试列表数据验证")
        let validateResult = CuttDB.validateListData(
            tableName: "test_table",
            data: testData,
            dbService: mockService
        )
        assert(validateResult, "列表数据验证失败")
        
        // 测试列表关系处理
        print("\n测试列表关系处理")
        let relationships = [
            "complexList": "parent_id",
            "nestedList": "group_id"
        ]
        let relationshipResult = CuttDB.handleListRelationships(
            tableName: "test_table",
            relationships: relationships,
            dbService: mockService
        )
        assert(relationshipResult, "列表关系处理失败")
        
        print("\n=== 复杂列表属性测试完成 ===")
    }
} 