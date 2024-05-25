import SwiftUI
import Firebase

struct ExpenseView: View {
    @State private var description: String = ""
    @State private var amount: String = ""
    @State private var expenses: [Expense] = []
    var username: String

    var body: some View {
        VStack {
            Text("Harcama Takibi")
                .font(.largeTitle)
                .padding()

            TextField("Açıklama", text: $description)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextField("Tutar", text: $amount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: addExpense) {
                Text("Harcama Ekle")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            List(expenses) { expense in
                HStack {
                    Text(expense.description)
                    Spacer()
                    Text("\(expense.amount, specifier: "%.2f")")
                }
            }
        }
        .onAppear(perform: fetchExpenses)
    }

    func addExpense() {
        guard let amountDouble = Double(amount) else { return }
        let db = Firestore.firestore()
        let newExpense = Expense(id: UUID().uuidString, description: description, amount: amountDouble)

        db.collection("users").document(username).collection("expenses").document(newExpense.id).setData(newExpense.toDictionary()) { error in
            if let error = error {
                print("Error adding expense: \(error)")
            } else {
                expenses.append(newExpense)
                description = ""
                amount = ""
            }
        }
    }

    func fetchExpenses() {
        let db = Firestore.firestore()
        guard let username = UserDefaults.standard.string(forKey: "username") else { return }

        db.collection("users").document(username).collection("expenses").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching expenses: \(error)")
            } else {
                if let snapshot = snapshot {
                    self.expenses = snapshot.documents.compactMap { document in
                        try? document.data(as: Expense.self)
                    }
                }
            }
        }
    }
}

struct Expense: Identifiable, Codable {
    var id: String
    var description: String
    var amount: Double

    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "description": description,
            "amount": amount
        ]
    }
}
