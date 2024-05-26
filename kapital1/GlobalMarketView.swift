import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GlobalMarketView: View {
    var username: String
    @Binding var balance: Double
    @State private var items: [MarketItem] = []

    var body: some View {
        VStack {
            Text("Global Market")
                .font(.largeTitle)
                .padding()

            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text("Fiyat: \(item.price, specifier: "%.2f")")
                        .font(.subheadline)
                    Button(action: {
                        buyItem(item: item)
                    }) {
                        Text("Satın Al")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            fetchMarketItems()
        }
    }

    func fetchMarketItems() {
        let db = Firestore.firestore()
        db.collection("global_market").getDocuments { snapshot, error in
            if let error = error {
                print("Global market öğelerini çekerken hata oluştu: \(error)")
            } else {
                if let snapshot = snapshot {
                    self.items = snapshot.documents.compactMap { document in
                        print("Document data: \(document.data())") // Debugging için
                        return try? document.data(as: MarketItem.self)
                    }
                    print("Fetched items: \(self.items)") // Debugging için
                }
            }
        }
    }

    func buyItem(item: MarketItem) {
        guard balance >= item.price else {
            print("Yetersiz bakiye.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)
        
        userRef.updateData([
            "balance": FieldValue.increment(-item.price)
        ]) { error in
            if let error = error {
                print("Error updating balance: \(error)")
            } else {
                self.balance -= item.price
                addUserBusiness(business: item)
            }
        }
    }
    
    func addUserBusiness(business: MarketItem) {
        let db = Firestore.firestore()
        let userBusinessRef = db.collection("users").document(username).collection("businesses").document(business.id ?? UUID().uuidString)
        
        do {
            try userBusinessRef.setData(from: business)
        } catch let error {
            print("Error adding business to user: \(error)")
        }
    }
}

struct MarketItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Double
}
