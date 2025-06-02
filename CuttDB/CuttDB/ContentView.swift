//
//  ContentView.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/5/30.
//

import SwiftUI

// MARK: - 数据库配置
struct DBConfig {
    static let tableName = "users"
    static let columns: [(name: String, type: String)] = [
        ("id", "INTEGER PRIMARY KEY AUTOINCREMENT"),
        ("name", "TEXT NOT NULL"),
        ("age", "INTEGER"),
        ("created_at", "TIMESTAMP DEFAULT CURRENT_TIMESTAMP")
    ]
    
    static var editableColumns: [(name: String, type: String)] {
        columns.filter { $0.name != "id" && $0.name != "created_at" }
    }
}

struct ContentView: View {
    @State private var message: String = "Database not initialized"
    @State private var queryResults: [[String: Any]] = []
    @State private var sortOrder: SortOrder = .descending
    @State private var selectedId: Int64? = nil
    @State private var showDeleteAlert: Bool = false
    @State private var showEditSheet: Bool = false
    @State private var showAddSheet: Bool = false
    @State private var editingRecord: [String: Any] = [:]
    private let dbService = CuttDBService()
    
    enum SortOrder {
        case ascending
        case descending
        
        var description: String {
            switch self {
            case .ascending: return "Early"
            case .descending: return "New"
            }
        }
        
        var sqlOrder: String {
            switch self {
            case .ascending: return "ASC"
            case .descending: return "DESC"
            }
        }
    }
    
    var body: some View {
        VStack {
            Text(message)
                .padding()
            
            HStack(spacing: 20) {
                Button(action: { showAddSheet = true }) {
                    Text("Add")
                        .frame(width: 72, height: 72)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: queryTestData) {
                    Text("Query")
                        .frame(width: 72, height: 72)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            if !queryResults.isEmpty {
                VStack {
                    HStack {
                        Picker("Sort Order", selection: $sortOrder) {
                            Text(SortOrder.ascending.description).tag(SortOrder.ascending)
                            Text(SortOrder.descending.description).tag(SortOrder.descending)
                        }
                        .pickerStyle(.segmented)
                        
                        if selectedId != nil {
                            Button(action: { showDeleteAlert = true }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.bordered)
                                    .tint(.red)
                        }
                    }
                    .padding(.horizontal)
                    .onChange(of: sortOrder) { _ in
                        queryTestData()
                    }
                    .frame(maxWidth: 400)
                    
                    ZStack {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedId = nil
                                }
                            }
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(0..<queryResults.count, id: \.self) { index in
                                    if let id = queryResults[index]["id"] as? Int64 {
                                        HStack(alignment: .top, spacing: 15) {
                                            Text("#\(id)")
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                                .frame(width: 50, alignment: .leading)
                                            
                                            VStack(alignment: .leading, spacing: 5) {
                                                ForEach(Array(queryResults[index].keys.sorted().filter { $0 != "id" }), id: \.self) { key in
                                                    if let value = queryResults[index][key] {
                                                        HStack(alignment: .top) {
                                                            Text("\(key):")
                                                                .fontWeight(.medium)
                                                            Text("\(String(describing: value))")
                                                        }
                                                    }
                                                }
                                            }
                                            .padding()
                                            .background(selectedId == id ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(selectedId == id ? Color.blue : Color.clear, lineWidth: 2)
                                            )
                                            .gesture(
                                                TapGesture(count: 1)
                                                    .onEnded { _ in
                                                        withAnimation(.easeInOut(duration: 0.2)) {
                                                            selectedId = selectedId == id ? nil : id
                                                        }
                                                    }
                                            )
                                            .simultaneousGesture(
                                                TapGesture(count: 2)
                                                    .onEnded { _ in
                                                        editingRecord = queryResults[index]
                                                        showEditSheet = true
                                                    }
                                            )
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .padding()
        .alert("Confirm Delete", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteSelectedRecord()
            }
        } message: {
            if let id = selectedId {
                Text("Are you sure you want to delete record #\(id)?")
            }
        }
        .sheet(isPresented: $showEditSheet) {
            EditRecordView(record: $editingRecord, onSave: { updatedRecord in
                updateRecord(updatedRecord)
            })
            .modifier(SheetModifier())
        }
        .sheet(isPresented: $showAddSheet) {
            AddRecordView(columns: DBConfig.editableColumns) { newRecord in
                insertNewRecord(newRecord)
            }
            .modifier(SheetModifier())
        }
        .onAppear {
            queryTestData()
        }
    }
    
    private func insertNewRecord(_ record: [String: Any]) {
        let columns = DBConfig.columns.map { "\($0.name) \($0.type)" }
        let success = dbService.executeWithTable(tableName: DBConfig.tableName, columns: columns) {
            dbService.insert(tableName: DBConfig.tableName, values: record)
        }
        if success {
            message = "Data inserted successfully"
            queryTestData()
        } else {
            message = "Failed to insert data"
        }
    }
    
    private func queryTestData() {
        let columns = DBConfig.columns.map { "\($0.name) \($0.type)" }
        var results: [[String: Any]] = []
        let success = dbService.executeWithTable(tableName: DBConfig.tableName, columns: columns) {
            results = dbService.select(
                tableName: DBConfig.tableName,
                columns: ["*"],
                whereClause: nil,
                orderBy: "created_at \(sortOrder.sqlOrder), id \(sortOrder.sqlOrder)"
            )
            return true
        }
        if success && !results.isEmpty {
            message = "Found \(results.count) records"
            queryResults = results
            selectedId = nil
        } else if success {
            message = "No records found"
            queryResults = []
            selectedId = nil
        } else {
            message = "Failed to ensure table exists"
        }
    }
    
    private func deleteSelectedRecord() {
        guard let id = selectedId else { return }
        
        if dbService.delete(tableName: DBConfig.tableName, whereClause: "id = \(id)") {
            message = "Record #\(id) deleted successfully"
            queryTestData() // 刷新数据
        } else {
            message = "Failed to delete record #\(id)"
        }
    }
    
    private func updateRecord(_ record: [String: Any]) {
        guard let id = record["id"] as? Int64 else { return }
        
        // 过滤掉不需要更新的字段
        var updateValues = record
        updateValues.removeValue(forKey: "id")
        updateValues.removeValue(forKey: "created_at")
        
        if dbService.update(
            tableName: DBConfig.tableName,
            values: updateValues,
            whereClause: "id = \(id)"
        ) {
            message = "Record #\(id) updated successfully"
            queryTestData() // 刷新数据
        } else {
            message = "Failed to update record #\(id)"
        }
    }
}

struct AddRecordView: View {
    @Environment(\.dismiss) private var dismiss
    let columns: [(name: String, type: String)]
    let onSave: ([String: Any]) -> Void
    
    @State private var fieldValues: [String: String] = [:]
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 主要信息部分
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Add New Record")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        // 只显示 name 和 age 字段，其他字段设为可选
                        TextField("Name", text: Binding(
                            get: { fieldValues["name"] ?? "" },
                            set: { fieldValues["name"] = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 30)
                        
                        TextField("Age", text: Binding(
                            get: { fieldValues["age"] ?? "" },
                            set: { fieldValues["age"] = $0 }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(height: 30)
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    
                }
                .padding()
            }
            .frame(minWidth: 400, minHeight: 500)
            .navigationTitle("Add New Record")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecord()
                    }
                }
            }
            .alert("Validation Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .navigationViewStyle(.automatic)
    }
    
    private func saveRecord() {
        // 验证必填字段
        if let name = fieldValues["name"], !name.isEmpty {
            var record: [String: Any] = [:]
            
            // 转换字段值
            for column in columns {
                if let value = fieldValues[column.name], !value.isEmpty {
                    if column.type.contains("INTEGER") {
                        if let intValue = Int(value) {
                            record[column.name] = intValue
                        } else {
                            alertMessage = "Invalid integer value for \(column.name)"
                            showAlert = true
                            return
                        }
                    } else {
                        record[column.name] = value
                    }
                }
            }
            
            onSave(record)
            dismiss()
        } else {
            alertMessage = "Name is required"
            showAlert = true
        }
    }
}

struct EditRecordView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var record: [String: Any]
    let onSave: ([String: Any]) -> Void
    
    @State private var fieldValues: [String: String] = [:]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Edit Record")
                            .font(.headline)
                            .padding(.bottom, 5)
                        
                        ForEach(Array(record.keys.sorted().filter { $0 != "id" && $0 != "created_at" }), id: \.self) { key in
                            TextField(key.capitalized, text: Binding(
                                get: { fieldValues[key] ?? "" },
                                set: { fieldValues[key] = $0 }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 30)
                        }
                    }
                    .padding()
                    .background(Color(NSColor.windowBackgroundColor))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                }
                .padding()
            }
            .frame(minWidth: 400, minHeight: 500)
            .navigationTitle("Edit Record #\(record["id"] as? Int64 ?? 0)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedRecord = record
                        for (key, value) in fieldValues {
                            if let intValue = Int(value) {
                                updatedRecord[key] = intValue
                            } else {
                                updatedRecord[key] = value
                            }
                        }
                        onSave(updatedRecord)
                        dismiss()
                    }
                }
            }
            .onAppear {
                // 初始化所有字段的值
                for (key, value) in record {
                    if key != "id" && key != "created_at" {
                        fieldValues[key] = String(describing: value)
                    }
                }
            }
        }
        .navigationViewStyle(.automatic)
    }
}

#Preview {
    ContentView()
}

struct SheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 13.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        } else {
            content
        }
    }
}
