import Foundation

import Foundation

struct RequiredProduct: Codable, Identifiable {
    var id: String { name } // `id` alanı yerine `name` alanını kullanıyoruz.
    var name: String
    var quantity: Int
}
