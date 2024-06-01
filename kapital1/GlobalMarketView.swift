import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct GlobalMarketView: View {
    var username: String
    @Binding var balance: Double
    var businessID: String
    @Binding var reloadTrigger: Bool
    @State private var items: [MarketItem] = []
    @State private var quantities: [String: Int] = [:]

    var body: some View {
        VStack {
            Text("Global Market")
                .font(.largeTitle)
                .padding()

            List(items) { item in
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text("Fiyat: \(item.price, specifier: "%.2f") ₺")
                                .font(.subheadline)
                        }
                        Spacer()
                        HStack {
                            Stepper("", value: Binding(
                                get: { quantities[item.id ?? ""] ?? 1 },
                                set: { quantities[item.id ?? ""] = $0 }
                            ), in: 1...Int.max)
                                .labelsHidden()

                            TextField("Adet", value: Binding(
                                get: { quantities[item.id ?? ""] ?? 1 },
                                set: { quantities[item.id ?? ""] = $0 }
                            ), formatter: NumberFormatter())
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .keyboardType(.numberPad)
                                .frame(width: 60)
                        }
                    }
                    Button(action: {
                        let quantity = quantities[item.id ?? ""] ?? 1
                        buyItem(item: item, quantity: quantity)
                    }) {
                        Text("Satın Al")
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding(.top, 4)
                }
                .padding(.vertical, 8)
            }
            .listStyle(InsetGroupedListStyle())
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
                        try? document.data(as: MarketItem.self)
                    }
                    print("Fetched items: \(self.items)")
                }
            }
        }
    }

    func buyItem(item: MarketItem, quantity: Int) {
        guard balance >= item.price * Double(quantity) else {
            print("Yetersiz bakiye.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)
        let productRef = userRef.collection("products").document(item.id ?? UUID().uuidString)
        
        db.runTransaction { (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                try userDocument = transaction.getDocument(userRef)
            } catch let error as NSError {
                errorPointer?.pointee = error
                return nil
            }
            
            guard let currentBalance = userDocument.data()?["balance"] as? Double else {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Balance not found"])
                errorPointer?.pointee = error
                return nil
            }
            
            if currentBalance < item.price * Double(quantity) {
                let error = NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Insufficient funds"])
                errorPointer?.pointee = error
                return nil
            }
            
            let productDocument: DocumentSnapshot
            do {
                try productDocument = transaction.getDocument(productRef)
            } catch {
                // If the document doesn't exist, create it with the initial quantity
                transaction.setData([
                    "name": item.name,
                    "price": item.price,
                    "quantity": quantity
                ], forDocument: productRef)
                transaction.updateData(["balance": currentBalance - item.price * Double(quantity)], forDocument: userRef)
                return nil
            }
            
            if let currentQuantity = productDocument.data()?["quantity"] as? Int {
                transaction.updateData(["quantity": currentQuantity + quantity], forDocument: productRef)
            } else {
                transaction.setData([
                    "name": item.name,
                    "price": item.price,
                    "quantity": quantity
                ], forDocument: productRef)
            }
            
            transaction.updateData(["balance": currentBalance - item.price * Double(quantity)], forDocument: userRef)
            
            return nil
        } completion: { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                self.balance -= item.price * Double(quantity)
                self.reloadTrigger.toggle() // Reload trigger'ı tetikle
                print("Transaction successfully committed!")
            }
        }
    }
}
