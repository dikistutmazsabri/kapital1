import SwiftUI

struct BusinessDetailView: View {
    var business: BusinessItem
    @State private var revenue: Double = 0.0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            Text("İşletme Detayları")
                .font(.largeTitle)
                .padding()
            
            Text("İşletme Adı: \(business.name)")
                .font(.title2)
                .padding()
            
            Text("Kazanç: \(revenue, specifier: "%.2f")")
                .font(.title2)
                .padding()
            
            List {
                // İşletme satışlarını burada listeleyebilirsiniz
            }
        }
        .onAppear {
            startRevenueGeneration()
        }
        .onDisappear {
            stopRevenueGeneration()
        }
    }

    func startRevenueGeneration() {
        timer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            generateRevenue()
        }
    }

    func stopRevenueGeneration() {
        timer?.invalidate()
    }

    func generateRevenue() {
        let earned = business.price * 0.1 // Örneğin, her 10 dakikada bir %10 kazanç
        revenue += earned
        // Burada kazancı Firestore'a kaydedebilirsiniz
    }
}
