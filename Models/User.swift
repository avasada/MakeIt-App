import Foundation

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var list: [MaterialItem]
    var email: String
    var interests: [String] = []
}
