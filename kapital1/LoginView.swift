import SwiftUI
import Firebase

struct LoginView: View {
    @Binding var registeredUsername: String
    @Binding var registeredPassword: String
    @Binding var registeredEmail: String
    @Binding var showRegisterView: Bool
    @Binding var isLoggedIn: Bool
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var loginError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack {
            Text("Giriş Yap")
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
            
            if loginError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button(action: {
                loginUser(username: username, password: password)
            }) {
                Text("Giriş Yap")
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: {
                showRegisterView = true
            }) {
                Text("Kayıt Ol")
                    .foregroundColor(.blue)
            }
            .padding(.top)
        }
        .onAppear {
            autoLogin()
        }
    }
    
    func loginUser(username: String, password: String) {
        let db = Firestore.firestore()
        db.collection("users").document(username).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let storedPassword = data?["password"] as? String ?? ""
                
                if storedPassword == password {
                    registeredUsername = username
                    registeredPassword = password // registeredPassword'ı güncelle
                    isLoggedIn = true
                    saveLoginDetails(username: username, password: password) // Giriş bilgilerini sakla
                } else {
                    loginError = true
                    errorMessage = "Şifre yanlış."
                }
            } else {
                loginError = true
                errorMessage = "Kullanıcı adı bulunamadı."
            }
        }
    }
    
    func saveLoginDetails(username: String, password: String) {
        UserDefaults.standard.setValue(username, forKey: "username")
        UserDefaults.standard.setValue(password, forKey: "password")
    }
    
    func autoLogin() {
        if let username = UserDefaults.standard.string(forKey: "username"), let password = UserDefaults.standard.string(forKey: "password") {
            self.username = username
            self.password = password
            loginUser(username: username, password: password)
        }
    }
}
