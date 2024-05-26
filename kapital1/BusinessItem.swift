import FirebaseFirestoreSwift

struct BusinessItem: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var price: Double
}
