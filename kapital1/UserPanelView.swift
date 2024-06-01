import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct UserPanelView: View {
    var username: String
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var userBusinesses: [BusinessItem] = []
    @State private var reloadTrigger = false
    @State private var timer: Timer?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Kullanıcı Paneli")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                        .padding(.leading, 20)
                    Spacer()
                    Button(action: {
                        isLoggedIn = false
                        UserDefaults.standard.removeObject(forKey: "username")
                        UserDefaults.standard.removeObject(forKey: "password")
                    }) {
                        Text("Çıkış")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 40)
                    .padding(.trailing, 20)
                }

                VStack(alignment: .leading, spacing: 20) {
                    Text("Hoş geldiniz, \(username)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.leading, 20)
                        .padding(.bottom, 10)

                    HStack {
                        Text("Hesap Bakiyesi:")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(appViewModel.balance, specifier: "%.2f") ₺")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(uiColor: UIColor.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                }

                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(userBusinesses) { business in
                            NavigationLink(destination: BusinessDetailView(business: business, username: username, balance: $appViewModel.balance)) {
                                HStack {
                                    Text(business.name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                            .padding(.horizontal, 20)
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
                        .padding(.horizontal, 20)

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
                        .padding(.horizontal, 20)

                        NavigationLink(destination: GlobalMarketView(username: username, balance: $appViewModel.balance, businessID: userBusinesses.first?.id ?? "", reloadTrigger: $reloadTrigger)) {
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
                        .padding(.horizontal, 20)

                        NavigationLink(destination: BusinessView(username: username, balance: $appViewModel.balance)) {
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
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                .padding(.top, 10)
            }
            .background(Color(uiColor: UIColor.systemBackground))
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                fetchUserBusinesses()
                appViewModel.username = username
                appViewModel.isLoggedIn = true
            }
            .onDisappear {
                appViewModel.isLoggedIn = false
            }
        }
    }

    func fetchBalance() {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let userBalance = data["balance"] as? Double {
                    appViewModel.balance = userBalance
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
