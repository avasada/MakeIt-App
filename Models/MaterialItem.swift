import Foundation
import FirebaseFirestoreSwift

struct MaterialItem: Identifiable, Codable, Hashable {
    
    @DocumentID var id: String?
    
    var name: String
    var quantity: Int
    var category: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MaterialItem, rhs: MaterialItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}

