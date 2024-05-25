import SwiftUI

struct UserPanelView: View {
    var username: String
    @Binding var isLoggedIn: Bool
    @State private var balance: Double = 300000.0

    var body: some View {
        VStack {
            Text("Kullanıcı Paneli")
                .font(.largeTitle)
                .padding()

            VStack(alignment: .leading, spacing: 20) {
                Text("Hoş geldiniz, \(username)")
                    .font(.title2)
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
            .padding()

            Spacer()

            Button(action: {
                logout()
            }) {
                Text("Çıkış Yap")
                    .font(.title2)
            }
            .padding()
        }
    }

    func logout() {
        // UserDefaults'daki bilgileri temizle
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "password")
        isLoggedIn = false
    }
}
