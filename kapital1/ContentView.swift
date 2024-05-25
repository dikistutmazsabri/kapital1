import SwiftUI
import Firebase

struct ContentView: View {
    @State private var isRegistered: Bool = false
    @State private var registeredUsername: String = ""
    @State private var registeredPassword: String = ""
    @State private var registeredEmail: String = ""
    @State private var showRegisterView: Bool = false
    @State private var showSuccessMessage: Bool = false
    @State private var isLoggedIn: Bool = false

    var body: some View {
        VStack {
            if showSuccessMessage {
                Text("Kayıt başarılı!")
                    .foregroundColor(.green)
                    .padding()
            }

            if isLoggedIn {
                UserPanelView(username: registeredUsername, isLoggedIn: $isLoggedIn)
                    .onAppear {
                        showSuccessMessage = false
                    }
            } else if showRegisterView {
                RegisterView(isRegistered: $isRegistered, registeredUsername: $registeredUsername, registeredPassword: $registeredPassword, registeredEmail: $registeredEmail, showRegisterView: $showRegisterView, showSuccessMessage: $showSuccessMessage)
            } else {
                LoginView(registeredUsername: $registeredUsername, registeredPassword: $registeredPassword, registeredEmail: $registeredEmail, showRegisterView: $showRegisterView, isLoggedIn: $isLoggedIn)
                    .onAppear {
                        showSuccessMessage = false
                    }
            }
        }
        .onAppear {
            autoLogin()
        }
    }

    func autoLogin() {
        if let username = UserDefaults.standard.string(forKey: "username"), let password = UserDefaults.standard.string(forKey: "password") {
            registeredUsername = username
            registeredPassword = password
            isLoggedIn = true
            showSuccessMessage = false
        }
    }
}
