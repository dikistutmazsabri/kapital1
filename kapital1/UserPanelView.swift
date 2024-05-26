import SwiftUI
import FirebaseFirestore

struct UserPanelView: View {
    var username: String
    @Binding var isLoggedIn: Bool
    @State private var balance: Double = 0.0
    @State private var userBusinesses: [BusinessItem] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("Kullanıcı Paneli")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Hoş geldiniz, \(username)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 10)
                    
                    HStack {
                        Text("Hesap Bakiyesi:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(balance, specifier: "%.2f")")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(uiColor: UIColor.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.horizontal)
                
                Spacer()
                
                ForEach(userBusinesses) { business in
                    NavigationLink(destination: BusinessDetailView(business: business)) {
                        Text(business.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }

                NavigationLink(destination: TransferView(username: username, onTransferCompleted: fetchBalance)) {
                    Text("Para Transferi")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                NavigationLink(destination: ExpenseView(username: username)) {
                    Text("Harcama Takibi")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                NavigationLink(destination: GlobalMarketView(username: username, balance: $balance)) {
                    Text("Global Market")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                NavigationLink(destination: BusinessView(username: username, balance: $balance)) {
                    Text("İşletmeler")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                
                Spacer()
                
                Button(action: {
                    isLoggedIn = false
                    UserDefaults.standard.removeObject(forKey: "username")
                    UserDefaults.standard.removeObject(forKey: "password")
                }) {
                    Text("Çıkış Yap")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color(uiColor: UIColor.systemBackground))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                fetchBalance()
                fetchUserBusinesses()
            }
        }
    }

    func fetchBalance() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let userBalance = data["balance"] as? Double {
                    balance = userBalance
                }
            } else {
                print("User document does not exist")
            }
        }
    }

    func fetchUserBusinesses() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)
        userRef.collection("businesses").getDocuments { snapshot, error in
            if let error = error {
                print("User businesses çekilirken hata oluştu: \(error)")
            } else {
                if let snapshot = snapshot {
                    self.userBusinesses = snapshot.documents.compactMap { document in
                        try? document.data(as: BusinessItem.self)
                    }
                }
            }
        }
    }
}
