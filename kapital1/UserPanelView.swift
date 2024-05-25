import SwiftUI
import FirebaseFirestore

struct UserPanelView: View {
    var username: String
    @Binding var isLoggedIn: Bool
    @State private var balance: Double = 0.0

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
                
                NavigationLink(destination: ProfileView(username: username)) {
                    Text("Profil")
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
            .onAppear(perform: fetchBalance)
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
}
