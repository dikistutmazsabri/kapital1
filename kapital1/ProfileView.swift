import SwiftUI
import Firebase

struct ProfileView: View {
    var username: String
    @State private var email: String = ""
    @State private var balance: Double = 0.0

    var body: some View {
        VStack {
            Text("Profil")
                .font(.largeTitle)
                .padding()

            TextField("Kullanıcı Adı", text: .constant(username))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .disabled(true)

            TextField("E-posta", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Text("Hesap Bakiyesi:")
                    .font(.title2)
                Spacer()
                Text("\(balance, specifier: "%.2f")")
                    .font(.title2)
                    .foregroundColor(.green)
            }
            .padding()
            
            Spacer()

            Button(action: {
                updateUserProfile()
            }) {
                Text("Profili Güncelle")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .padding()
        .onAppear {
            fetchUserProfile()
        }
    }

    func fetchUserProfile() {
        let db = Firestore.firestore()
        db.collection("users").document(username).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                self.email = data?["email"] as? String ?? ""
                self.balance = data?["balance"] as? Double ?? 0.0
            }
        }
    }

    func updateUserProfile() {
        let db = Firestore.firestore()
        db.collection("users").document(username).updateData([
            "email": email,
            "balance": balance
        ]) { error in
            if let error = error {
                print("Error updating profile: \(error)")
            } else {
                print("Profile successfully updated")
            }
        }
    }
}//
//  ProfileView.swift
//  kapital1
//
//  Created by Burak Polat on 25.05.2024.
//

import Foundation
