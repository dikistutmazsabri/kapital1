import SwiftUI
import Firebase
import FirebaseFirestore

class AppViewModel: ObservableObject {
    @Published var balance: Double = 0.0
    @Published var products: [ProductItem] = []
    @Published var salesLog: [String] = []
    var username: String = ""
    var timer: Timer?
    var isLoggedIn: Bool = false {
        didSet {
            if isLoggedIn {
                startSellingProducts()
                listenToUserChanges()
            } else {
                stopSellingProducts()
            }
        }
    }

    init() {
        fetchUserData()
    }

    func fetchUserData() {
        guard !username.isEmpty else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)

        userRef.getDocument { document, error in
            if let document = document, document.exists {
                self.balance = document.data()?["balance"] as? Double ?? 0.0
                self.fetchProducts()
                self.fetchSalesLog()
            } else {
                print("Kullanıcı verileri çekilemedi: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }

    func fetchProducts() {
        guard !username.isEmpty else { return }
        let db = Firestore.firestore()
        let productsRef = db.collection("users").document(username).collection("products")

        productsRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.products = snapshot.documents.compactMap { document in
                    try? document.data(as: ProductItem.self)
                }
            } else {
                print("Ürünler çekilirken hata oluştu: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }

    func fetchSalesLog() {
        guard !username.isEmpty else { return }
        let db = Firestore.firestore()
        let salesLogRef = db.collection("users").document(username).collection("salesLog")

        salesLogRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                self.salesLog = snapshot.documents.compactMap { document in
                    document.data()["log"] as? String
                }
            } else {
                print("Satış logları çekilirken hata oluştu: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }

    func startSellingProducts() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            self.sellProducts()
        }
    }

    func stopSellingProducts() {
        timer?.invalidate()
        timer = nil
    }

    func sellProducts() {
        guard !username.isEmpty else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)
        let productsRef = userRef.collection("products")

        productsRef.getDocuments { snapshot, error in
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    if let product = try? document.data(as: ProductItem.self), product.quantity > 0 {
                        let soldQuantity = min(product.quantity, 10)
                        let revenue = Double(soldQuantity) * product.price
                        let newQuantity = product.quantity - soldQuantity

                        userRef.updateData([
                            "balance": FieldValue.increment(revenue)
                        ]) { error in
                            if let error = error {
                                print("Bakiye güncellenirken hata oluştu: \(error.localizedDescription)")
                            } else {
                                productsRef.document(product.id ?? "").updateData([
                                    "quantity": newQuantity
                                ]) { error in
                                    if let error = error {
                                        print("Ürün miktarı güncellenirken hata oluştu: \(error.localizedDescription)")
                                    } else {
                                        let logEntry = "\(product.name) ürününden \(soldQuantity) adet satıldı. Gelir: \(revenue)"
                                        self.salesLog.append(logEntry)
                                        print(logEntry)
                                        self.addSalesLogToFirestore(logEntry: logEntry)
                                        self.fetchUserData() // Update user data after sale
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func addSalesLogToFirestore(logEntry: String) {
        guard !username.isEmpty else { return }
        let db = Firestore.firestore()
        let salesLogRef = db.collection("users").document(username).collection("salesLog").document()

        salesLogRef.setData(["log": logEntry]) { error in
            if let error = error {
                print("Satış logu Firestore'a eklenirken hata oluştu: \(error.localizedDescription)")
            }
        }
    }

    func listenToUserChanges() {
        guard !username.isEmpty else { return }
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(username)

        userRef.addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, snapshot.exists {
                self.balance = snapshot.data()?["balance"] as? Double ?? 0.0
                self.fetchProducts()
                self.fetchSalesLog()
            } else {
                print("Kullanıcı değişiklikleri dinlenirken hata oluştu: \(error?.localizedDescription ?? "Bilinmeyen hata")")
            }
        }
    }
}
