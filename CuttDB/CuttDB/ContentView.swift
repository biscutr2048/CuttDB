//
//  ContentView.swift
//  CuttDB
//
//  Created by BISCUTR@QQ.COM on 2025/5/30.
//

import SwiftUI

struct ContentView: View {
    @State private var message: String = "Database not initialized"
    @State private var queryResults: [[String: Any]] = []
    @State private var sortOrder: SortOrder = .descending
    private let dbService = CuttDBService()
    
    enum SortOrder {
        case ascending
        case descending
        
        var description: String {
            switch self {
            case .ascending: return "Oldest First"
            case .descending: return "Newest First"
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
                Button(action: createTestTable) {
                    Text("Create Test Table")
                        .frame(width: 100, height: 100)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: insertTestData) {
                    Text("Insert Test Data")
                        .frame(width: 100, height: 100)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: queryTestData) {
                    Text("Query Test Data")
                        .frame(width: 100, height: 100)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            if !queryResults.isEmpty {
                VStack {
                    Picker("Sort Order", selection: $sortOrder) {
                        Text(SortOrder.ascending.description).tag(SortOrder.ascending)
                        Text(SortOrder.descending.description).tag(SortOrder.descending)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: sortOrder) { _ in
                        queryTestData()
                    }
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(0..<queryResults.count, id: \.self) { index in
                                HStack(alignment: .top, spacing: 15) {
                                    if let id = queryResults[index]["id"] as? Int64 {
                                        Text("#\(id)")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                            .frame(width: 50, alignment: .leading)
                                    }
                                    
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
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: .infinity)
                }
            }
        }
        .padding()
    }
    
    private func createTestTable() {
        let columns = [
            "id INTEGER PRIMARY KEY AUTOINCREMENT",
            "name TEXT NOT NULL",
            "age INTEGER",
            "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
        ]
        
        if dbService.createTable(tableName: "users", columns: columns) {
            message = "Table created successfully"
            queryResults = []
        } else {
            message = "Failed to create table"
        }
    }
    
    private func insertTestData() {
        let values: [String: Any] = [
            "name": "John Doe",
            "age": 30
        ]
        
        if dbService.insert(tableName: "users", values: values) {
            message = "Data inserted successfully"
            queryResults = []
        } else {
            message = "Failed to insert data"
        }
    }
    
    private func queryTestData() {
        let results = dbService.select(
            tableName: "users",
            columns: ["*"],
            whereClause: nil,
            orderBy: "created_at \(sortOrder.sqlOrder), id \(sortOrder.sqlOrder)"
        )
        if !results.isEmpty {
            message = "Found \(results.count) records"
            queryResults = results
        } else {
            message = "No records found"
            queryResults = []
        }
    }
}

#Preview {
    ContentView()
}
