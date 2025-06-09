import SwiftUI

struct ContentView: View {
    // 推荐直接用 CuttDB 实例
    private let db: CuttDB
    
    init() {
        // 你可以自定义 dbPath
        let config = CuttDBServiceConfiguration(dbPath: "cutt_db.sqlite")
        self.db = CuttDB(configuration: config)
    }
    
    var body: some View {
        VStack {
            Text("CuttDB Demo")
            // 这里可以添加更多与 db 相关的操作
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 