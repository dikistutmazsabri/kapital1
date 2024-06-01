import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BusinessView: View {
    var username: String
    @Binding var balance: Double
    @State private var businesses: [BusinessItem] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("İşletmeler")
                .font(.largeTitle)
                .bold()
                .padding(.top)

            if businesses.isEmpty {
                ProgressView("Yükleniyor...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(businesses) { business in
                            BusinessCardView(business: business) {
                                buyBusiness(business: business)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .onAppear {
            fetchBusinesses()
        }
    }

    func fetchBusinesses() {
        let db = Firestore.firestore()
        db.collection("businesses").getDocuments { snapshot, error in
            if let error = error {
                print("İşletmeleri çekerken hata oluştu: \(error)")
            } else {
                if let snapshot = snapshot {
                    self.businesses = snapshot.documents.compactMap { document in
                        do {
                            let data = try document.data(as: BusinessItem.self)
                            print("Document data: \(data)")
                            return data
                        } catch let error {
                            print("Belge verisi işlenirken hata oluştu: \(error)")
                            return nil
                        }
                    }
                    print("Fetched businesses: \(self.businesses)")
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
                print("Bakiye güncellenirken hata oluştu: \(error)")
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
            print("İşletmeyi kullanıcıya eklerken hata oluştu: \(error)")
        }
    }
}

struct BusinessCardView: View {
    var business: BusinessItem
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(business.name)
                .font(.headline)
                .bold()
            Text("Fiyat: \(business.price, specifier: "%.2f") ₺")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button(action: {
                action()
            }) {
                Text("Satın Al")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}


