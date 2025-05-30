//
//  ContentView.swift
//  CuttDB
//
//  Created by SHIJIAN on 2025/5/30.
//

import SwiftUI

struct ContentView: View {
    @State private var message: String = "Database not initialized"
    private let dbService = DatabaseService()
    
    var body: some View {
        VStack {
            Text(message)
                .padding()
            
            Button("Create Test Table") {
                createTestTable()
            }
            .padding()
            
            Button("Insert Test Data") {
                insertTestData()
            }
            .padding()
            
            Button("Query Test Data") {
                queryTestData()
            }
            .padding()
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
        } else {
            message = "Failed to insert data"
        }
    }
    
    private func queryTestData() {
        let results = dbService.select(tableName: "users")
        if !results.isEmpty {
            message = "Found \(results.count) records: \(results)"
        } else {
            message = "No records found"
        }
    }
}

#Preview {
    ContentView()
}
