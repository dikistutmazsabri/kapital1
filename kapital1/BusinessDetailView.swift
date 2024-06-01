import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct BusinessDetailView: View {
    var business: BusinessItem
    var username: String
    @Binding var balance: Double
    @State private var availableProducts: [RequiredProduct] = []
    @State private var missingProducts: [RequiredProduct] = []
    @State private var hasAllRequiredProducts: Bool = false
    @State private var isSalesLogExpanded = false
    @State private var reloadTrigger = false

    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        VStack {
            Text("\(business.name) Yönetim Paneli")
                .font(.largeTitle)
                .padding()

            if hasAllRequiredProducts {
                Text("\(business.name) işletmeniz çalışıyor.")
                    .font(.title2)
                    .foregroundColor(.green)
                    .padding(.bottom, 10)
            } else {
                Text("\(business.name) ürünleri eksik.")
                    .font(.title2)
                    .foregroundColor(.red)
                    .padding(.bottom, 10)

                ScrollView {
                    ForEach(missingProducts) { product in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(product.name)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                Text("Hiç ürün yok")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            Spacer()
                            NavigationLink(destination: GlobalMarketView(username: username, balance: $balance, businessID: business.id ?? "", reloadTrigger: $reloadTrigger)) {
                                Text("Ürün Al")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .frame(maxHeight: 150)
            }

            ScrollView {
                ForEach(availableProducts) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("\(product.quantity) adet mevcut")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .frame(maxHeight: 150)

            DisclosureGroup("Satış Logları", isExpanded: $isSalesLogExpanded) {
                ScrollView {
                    ForEach(appViewModel.salesLog, id: \.self) { logEntry in
                        Text(logEntry)
                            .font(.caption)
                            .padding(.vertical, 2)
                    }
                }
                .frame(maxHeight: 150)
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .onAppear {
            fetchMissingProducts()
        }
        .onChange(of: reloadTrigger) { _, _ in
            fetchMissingProducts()
        }
    }

    func fetchMissingProducts() {
        let db = Firestore.firestore()
        let businessRef = db.collection("users").document(username).collection("businesses").document(business.id ?? UUID().uuidString)

        businessRef.getDocument { document, error in
            if let error = error {
                print("Eksik ürünler çekilirken hata oluştu: \(error)")
            } else {
                if let document = document, let data = document.data() {
                    let requiredProducts = data["requiredProducts"] as? [[String: Any]] ?? []
                    var missingProducts: [RequiredProduct] = []
                    var availableProducts: [RequiredProduct] = []

                    let dispatchGroup = DispatchGroup()

                    for requiredProduct in requiredProducts {
                        dispatchGroup.enter()
                        let name = requiredProduct["name"] as? String ?? ""
                        let quantity = requiredProduct["quantity"] as? Int ?? 0

                        let productRef = db.collection("users").document(username).collection("products").whereField("name", isEqualTo: name)
                        productRef.getDocuments { snapshot, error in
                            if let snapshot = snapshot, snapshot.documents.isEmpty {
                                missingProducts.append(RequiredProduct(name: name, quantity: 0))
                            } else if let snapshot = snapshot, let productData = snapshot.documents.first?.data(), let currentQuantity = productData["quantity"] as? Int {
                                if currentQuantity < quantity {
                                    missingProducts.append(RequiredProduct(name: name, quantity: quantity - currentQuantity))
                                } else {
                                    availableProducts.append(RequiredProduct(name: name, quantity: currentQuantity))
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }

                    dispatchGroup.notify(queue: .main) {
                        self.missingProducts = missingProducts
                        self.availableProducts = availableProducts
                        self.hasAllRequiredProducts = missingProducts.isEmpty
                    }
                }
            }
        }
    }
}
