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

## Implementation Status Analysis (2024-03-21)

### Legend
- 💯 Fully Implemented
- 1️⃣ Partially Implemented
- ➡️ Not Implemented or Minimal Implementation
- 🈳 Not Implemented
- 🈶 Implemented
- 🌰 Example/Test

### Module Implementation Status

#### Create Module
- auto.get create sql 💯 - Implemented through `TableDefinitionManager` for automatic SQL generation
- auto.create when need, if not exists 💯 - Implemented through `ensureTableExists` for automatic table creation
- auto.create sub-table when listing 💯 - Implemented through `handleListProperties` for automatic sub-table creation
- auto.index local, with listing ➡️ - Local index creation pending implementation

#### Select Module
- mech. load response local.offline 💯 - Implemented complete offline query support through `queryObjects` and `queryWithPagination`
- auto.select object to sql 💯 - Implemented object query through `queryObject`
- auto.select obj.list to sql paged 💯 - Implemented pagination query through `queryWithPagination`
- auto.select by biz key and list 🈳 - Business key query pending implementation

#### Insert Module
- mech.save response 💯 - Implemented complete save functionality through `insertObject`
- op.save object to insert sql 💯 - Implemented object insertion through `insertObject`
- op.save obj.list to insert sql 💯 - Implemented batch insertion through `insertObject`

#### Update Module
- op.save object to update sql 💯 - Implemented object update through `updateObject`
- op.save obj.list to update sql 💯 - Implemented batch update through `updateObject`

#### Delete Module
- op.delete update to aged 🈳 - Data aging mechanism pending implementation
- op.delete batch with transaction 💯 - Implemented batch deletion with transaction support through `deleteObjects`

#### Align Module
- upgrade dest-table from src-table 💯 - Implemented table structure auto-upgrade through `upgradeTableStructure`
- drop missing, testing, debug-if 💯 - Implemented missing data cleanup through `dropMissingData`
- cleanup duplicates 💯 - Implemented duplicate data cleanup through `cleanupDuplicates`

#### Mechanism Module
- pair table to req, obj_list, paged 💯 - Implemented request-table pairing through `QueryManager`
- json object gt 3.38 💯 - Implemented complete JSON object support through `JSONDecoder`
- vector table 🈳 - Vector table support pending implementation

#### PARADIGM Module
- BIZ-DEF, CRUD by occasion, testing 💯 - Implemented complete test coverage for all CRUD operations

### Major Updates
1. Updated Select module implementation status, confirmed complete implementation of offline query and pagination
2. Updated Delete module implementation status, added batch deletion and transaction support
3. Updated Align module implementation status, confirmed complete implementation of table structure upgrade, data cleanup, and duplicate cleanup
4. Updated Mechanism module implementation status, confirmed complete implementation of JSON object support
5. Updated PARADIGM module implementation status, confirmed complete test coverage

### Next Steps
1. Implement local index creation for better query performance
2. Implement business key query functionality
3. Implement data aging mechanism
4. Add vector table support
5. Optimize batch operation performance
6. Enhance error handling and logging
7. Improve documentation and example code


---


## for Users

- manage SQLite table structs
- need auto response process
- gen SQL developers
- recover response
- deal with listing and properties, even sub-table automatically.

---

## Testing
CuttDB employs a layered testing architecture to ensure code quality and reliability:

### Test Architecture
- Service Layer Tests: Validates specific implementations of `CuttDBService`
- Interface Layer Tests: Verifies public interfaces of `CuttDB`
- Uses `MockCuttDBService` to simulate database operations

### Test Modules
- Create Module: Tests for table definitions, sub-tables, and automatic creation
- Select Module: Tests for offline queries and pagination
- InsertUpdate Module: Tests for SQL generation and transaction handling
- Delete Module: Tests for data aging and batch deletion
- Align Module: Tests for table structure upgrades and data cleanup
- ListProperties Module: Tests for complex list handling
- Mechanism Module: Tests for index management and response processing

### Test Execution
- Uses `CuttDBTest` for unified test management
- Supports both individual module testing and full test suite execution
- Provides detailed test result output


---


## MIT LICENSE

Copyright (c) 2025 BISCUTR

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
