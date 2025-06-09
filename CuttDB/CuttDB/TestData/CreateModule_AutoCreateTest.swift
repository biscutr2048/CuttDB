import Foundation

/// 创建模块 - 自动创建表测试
class CreateModule_AutoCreateTest: CuttDBTestCase {
    override func runTests() {
        print("\n=== 自动创建表测试 ===")
        
        // 测试数据
        let basicColumns: [String: String] = [
            "id": "INTEGER",
            "name": "TEXT",
            "created_at": "TEXT"
        ]
        
        let complexColumns: [String: String] = [
            "id": "INTEGER",
            "name": "TEXT",
            "email": "TEXT",
            "age": "INTEGER",
            "score": "REAL",
            "is_active": "INTEGER",
            "metadata": "TEXT",
            "created_at": "TEXT",
            "updated_at": "TEXT"
        ]
        
        let tableConstraints: [String: String] = [
            "PRIMARY KEY": "(id)",
            "UNIQUE": "(email)",
            "CHECK": "(age >= 0)"
        ]
        
        let indexColumns: [String: [String]] = [
            "idx_email": ["email"],
            "idx_name_email": ["name", "email"],
            "idx_created_at": ["created_at"]
        ]
        
        // 创建Mock服务
        let mockService = MockCuttDBService()
        
        // 测试基本表创建
        print("\n测试基本表创建")
        let basicResult = CuttDB.ensureTableExists(
            tableName: "basic_table",
            columns: basicColumns,
            dbService: mockService
        )
        assert(basicResult, "基本表创建失败")
        
        // 测试复杂表创建
        print("\n测试复杂表创建")
        let complexResult = CuttDB.ensureTableExists(
            tableName: "complex_table",
            columns: complexColumns,
            constraints: tableConstraints,
            dbService: mockService
        )
        assert(complexResult, "复杂表创建失败")
        
        // 测试表已存在的情况
        print("\n测试表已存在的情况")
        mockService.shouldTableExist = true
        let existingResult = CuttDB.ensureTableExists(
            tableName: "existing_table",
            columns: basicColumns,
            dbService: mockService
        )
        assert(existingResult, "处理已存在表失败")
        
        // 测试表结构验证
        print("\n测试表结构验证")
        let validationResult = CuttDB.validateTableStructure(
            tableName: "test_table",
            expectedColumns: complexColumns,
            dbService: mockService
        )
        assert(validationResult, "表结构验证失败")
        
        // 测试自动创建索引
        print("\n测试自动创建索引")
        let indexResult = CuttDB.createIndexesIfNeeded(
            tableName: "test_table",
            indexes: indexColumns,
            dbService: mockService
        )
        assert(indexResult, "自动创建索引失败")
        
        // 测试索引已存在的情况
        print("\n测试索引已存在的情况")
        mockService.shouldIndexExist = true
        let existingIndexResult = CuttDB.createIndexesIfNeeded(
            tableName: "test_table",
            indexes: ["idx_email": ["email"]],
            dbService: mockService
        )
        assert(existingIndexResult, "处理已存在索引失败")
        
        // 测试复合索引创建
        print("\n测试复合索引创建")
        let compositeIndexResult = CuttDB.createIndexIfNeeded(
            tableName: "test_table",
            indexName: "idx_name_email",
            columns: ["name", "email"],
            dbService: mockService
        )
        assert(compositeIndexResult, "复合索引创建失败")
        
        print("\n=== 自动创建表测试完成 ===")
    }
} 