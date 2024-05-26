import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BusinessView: View {
    var username: String
    @Binding var balance: Double
    @State private var businesses: [BusinessItem] = []

    var body: some View {
        VStack {
            Text("İşletmeler")
                .font(.largeTitle)
                .padding()

            List(businesses) { business in
                VStack(alignment: .leading) {
                    Text(business.name)
                        .font(.headline)
                    Text("Fiyat: \(business.price, specifier: "%.2f")")
                        .font(.subheadline)
                    Button(action: {
                        buyBusiness(business: business)
                    }) {
                        Text("Satın Al")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .onAppear {
            fetchBusinesses()
        }
    }

    func fetchBusinesses() {
        let db = Firestore.firestore()
        db.collection("Businesses").getDocuments { snapshot, error in
            if let error = error {
                print("İşletmeleri çekerken hata oluştu: \(error)")
            } else {
                if let snapshot = snapshot {
                    self.businesses = snapshot.documents.compactMap { document in
                        try? document.data(as: BusinessItem.self)
                    }
                }
            }
        }
    }

    func buyBusiness(business: BusinessItem) {
        guard balance >= business.price else {
            print("Yetersiz bakiye.")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)
        
        userRef.updateData([
            "balance": FieldValue.increment(-business.price)
        ]) { error in
            if let error = error {
                print("Error updating balance: \(error)")
            } else {
                self.balance -= business.price
                addUserBusiness(business: business)
            }
        }
    }
    
    func addUserBusiness(business: BusinessItem) {
        let db = Firestore.firestore()
        let userBusinessRef = db.collection("users").document(username).collection("businesses").document(business.id ?? UUID().uuidString)
        
        do {
            try userBusinessRef.setData(from: business)
        } catch let error {
            print("Error adding business to user: \(error)")
        }
    }
}
