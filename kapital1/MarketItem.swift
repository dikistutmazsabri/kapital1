import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MarketItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Double
}
