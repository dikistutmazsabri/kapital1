import SwiftUI
import Firebase

struct TransferView: View {
    var username: String
    @State private var recipientUsername: String = ""
    @State private var amount: String = ""
    @State private var transferMessage: String = ""
    @State private var transactions: [Transaction] = []
    var onTransferCompleted: () -> Void

    var body: some View {
        VStack {
            Text("Para Transferi")
                .font(.largeTitle)
                .padding()

            TextField("Alıcı Kullanıcı Adı", text: $recipientUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Tutar", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                transferMoney()
            }) {
                Text("Gönder")
                    .font(.title2)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            if !transferMessage.isEmpty {
                Text(transferMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            List(transactions) { transaction in
                HStack {
                    Text(transaction.sender == username ? "Gönderildi: \(transaction.recipient)" : "Alındı: \(transaction.sender)")
                    Spacer()
                    Text("\(transaction.amount, specifier: "%.2f")")
                        .foregroundColor(transaction.sender == username ? .red : .green)
                    Text("\(transaction.timestamp, formatter: dateFormatter)")
                }
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: fetchTransactions)
    }

    func transferMoney() {
        let db = Firestore.firestore()
        guard let amountDouble = Double(amount) else {
            transferMessage = "Lütfen geçerli bir tutar girin."
            return
        }

        let senderRef = db.collection("users").document(username)
        let recipientRef = db.collection("users").document(recipientUsername)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let senderDocument: DocumentSnapshot
            let recipientDocument: DocumentSnapshot
            do {
                try senderDocument = transaction.getDocument(senderRef)
                try recipientDocument = transaction.getDocument(recipientRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            guard let senderBalance = senderDocument.data()?["balance"] as? Double,
                  let recipientBalance = recipientDocument.data()?["balance"] as? Double else {
                return nil
            }

            if senderBalance < amountDouble {
                transferMessage = "Yetersiz bakiye."
                return nil
            }

            transaction.updateData(["balance": senderBalance - amountDouble], forDocument: senderRef)
            transaction.updateData(["balance": recipientBalance + amountDouble], forDocument: recipientRef)

            let newTransaction = Transaction(id: UUID().uuidString, sender: username, recipient: recipientUsername, amount: amountDouble, timestamp: Date())
            let transactionRef = db.collection("transactions").document(newTransaction.id)
            transaction.setData(newTransaction.toDictionary(), forDocument: transactionRef)

            return nil
        }) { (object, error) in
            if let error = error {
                transferMessage = "Hata: \(error.localizedDescription)"
            } else {
                transferMessage = "Transfer başarılı!"
                fetchTransactions()
                onTransferCompleted()
            }
        }
    }

    func fetchTransactions() {
        let db = Firestore.firestore()

        db.collection("transactions").whereField("sender", isEqualTo: username).getDocuments { senderSnapshot, error in
            if let error = error {
                print("Error fetching transactions: \(error)")
            } else {
                if let senderSnapshot = senderSnapshot {
                    let sentTransactions = senderSnapshot.documents.compactMap { document in
                        try? document.data(as: Transaction.self)
                    }
                    db.collection("transactions").whereField("recipient", isEqualTo: username).getDocuments { recipientSnapshot, error in
                        if let error = error {
                            print("Error fetching transactions: \(error)")
                        } else {
                            if let recipientSnapshot = recipientSnapshot {
                                let receivedTransactions = recipientSnapshot.documents.compactMap { document in
                                    try? document.data(as: Transaction.self)
                                }
                                self.transactions = sentTransactions + receivedTransactions
                            }
                        }
                    }
                }
            }
        }
    }
}

struct Transaction: Identifiable, Codable {
    var id: String
    var sender: String
    var recipient: String
    var amount: Double
    var timestamp: Date

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "sender": sender,
            "recipient": recipient,
            "amount": amount,
            "timestamp": timestamp
        ]
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
