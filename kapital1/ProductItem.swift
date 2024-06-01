import SwiftUI
import FirebaseFirestoreSwift

struct ProductItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var quantity: Int
    var price: Double
}
