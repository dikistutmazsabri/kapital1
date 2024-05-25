import SwiftUI
import Firebase

struct RegisterView: View {
    @Binding var isRegistered: Bool
    @Binding var registeredUsername: String
    @Binding var registeredPassword: String
    @Binding var registeredEmail: String
    @Binding var showRegisterView: Bool
    @Binding var showSuccessMessage: Bool
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var email: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var isConfirmPasswordVisible: Bool = false
    
    var body: some View {
        VStack {
            Text("Kayıt Ol")
                .font(.largeTitle)
                .padding()
            
            TextField("Kullanıcı Adı", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack {
                if isPasswordVisible {
                    TextField("Şifre", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                }
                .padding(.trailing)
            }
            .padding(.horizontal)
            
            HStack {
                if isConfirmPasswordVisible {
                    TextField("Şifreyi Onayla", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Şifreyi Onayla", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button(action: {
                    isConfirmPasswordVisible.toggle()
                }) {
                    Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                }
                .padding(.trailing)
            }
            .padding(.horizontal)
            
            TextField("E-posta", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                if password == confirmPassword && !username.isEmpty && !email.isEmpty {
                    registerUser(username: username, password: password, email: email)
                }
            }) {
                Text("Kayıt Ol")
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: {
                showRegisterView = false
            }) {
                Text("Geri")
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
    }
    
    func registerUser(username: String, password: String, email: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "username": username,
            "password": password,
            "email": email,
            "balance": 300000.0 // Balance alanını burada 300000 olarak ekliyoruz
        ]
        
        db.collection("users").document(username).setData(userData) { error in
            if let error = error {
                print("Error writing document: \(error)")
            } else {
                print("Document successfully written!")
                registeredUsername = username
                registeredPassword = password
                registeredEmail = email
                showSuccessMessage = true
                isRegistered = true
                showRegisterView = false
            }
        }
    }
}
