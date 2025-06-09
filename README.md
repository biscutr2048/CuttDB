
CuttDB

created by @biscutr2048

a sqlite3 access automation model

---

# top requirements
![CuttDB requirements](cuttdb_feature_0607.png)

## json friendly
    * sqlite 3.38 higher
        ** iOS 2020
        ** macos 11


---

## Implementation Status Analysis (2025-06-09)

### Legend
- 💯 Fully Implemented
- 1️⃣ Partially Implemented
- ➡️ Not Implemented or Minimal Implementation
- 🈳 Not Implemented
- 🈶 Implemented
- 🌰 Example/Test

### Module Implementation Status

#### Create Module
- auto.get create sql 💯 - Implemented through `extractTableDefinition` and `generateSQL` methods for automatic SQL generation
- auto.create when need, if not exists 💯 - Implemented through `ensureTableExists` for automatic table creation
- auto.create sub-table when listing 💯 - Implemented through `handleListProperties` for automatic sub-table creation
- auto.index local, with listing ➡️ - Local index creation pending implementation

#### Select Module
- mech. load response local.offline 1️⃣ - Basic recovery implemented via `restoreLastResponse` and `restoreSubTableResponse`, offline mode needs enhancement
- auto.select object to sql 1️⃣ - Basic query implemented, object mapping needs improvement
- auto.select obj.list to sql paged ➡️ - Pagination query pending implementation
- auto.select by biz key and list 🈳 - Business key query pending implementation

#### Insert Module
- mech.save response 1️⃣ - Basic save functionality implemented, automation needs enhancement
- op.save object to insert sql 💯 - Fully implemented through `insert` method
- op.save obj.list to insert sql 💯 - Implemented through `handleListProperties` for batch insertion

#### Update Module
- op.save object to update sql 💯 - Fully implemented through `update` method
- op.save obj.list to update sql 💯 - Implemented through `handleListProperties` for batch updates

#### Delete Module
- op.delete update to aged 🈳 - Data aging mechanism pending implementation

#### PARADIGM Module
- BIZ-DEF, CRUD by occasion, testing 🌰 - Examples available, testing needs enhancement

#### Drop Module
- drop missing, testing, debug-if ➡️ - Missing data cleanup pending implementation

#### Align Module
- upgrade dest-table from src-table ➡️ - Table structure auto-upgrade pending implementation

#### Mechanism Module
- pair table to req, obj_list, paged 💯 - Fully implemented through `requestIndexKey` for request-table pairing
- json object gt 3.38 🈶 - JSON object support implemented, including nested structures and lists
- vector table 🈳 - Vector table support pending implementation

### Major Updates
1. Marked `auto.get create sql` as 💯 due to implementation through `extractTableDefinition` and `generateSQL`
2. Marked `auto.create sub-table when listing` as 💯 due to implementation through `handleListProperties`
3. Marked `op.save obj.list to insert sql` and `op.save obj.list to update sql` as 💯 due to implementation through `handleListProperties`
4. Updated implementation descriptions to accurately reflect current code state

### Next Steps
1. Implement local index creation for better query performance
2. Enhance offline mode functionality for response loading
3. Implement pagination support for list queries
4. Add business key query capabilities
5. Implement data aging mechanism
6. Add missing data cleanup functionality
7. Implement table structure auto-upgrade
8. Add vector table support for advanced data structures


---


## for Users

- manage SQLite table structs
- need auto response process
- gen SQL developers
- recover response
- deal with listing and properties, even sub-table automatically.

---

## Testing
CuttDB 采用分层测试架构，确保代码质量和可靠性：

### 测试架构
- 服务层测试：验证 `CuttDBService` 的具体实现
- 接口层测试：验证 `CuttDB` 的公共接口
- 使用 `MockCuttDBService` 模拟数据库操作

### 测试模块
- Create Module：表定义、子表、自动创建测试
- Select Module：离线查询、分页查询测试
- InsertUpdate Module：SQL生成、事务处理测试
- Delete Module：数据老化、批量删除测试
- Align Module：表结构升级、数据清理测试
- ListProperties Module：复杂列表测试
- Mechanism Module：索引管理、响应处理测试

### 测试执行
- 使用 `CuttDBTest` 统一管理测试执行
- 支持单个模块测试和全量测试
- 提供详细的测试结果输出


---


## MIT LICENSE

Copyright (c) 2025 BISCUTR

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
