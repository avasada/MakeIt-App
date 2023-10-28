//
//  SQL_Project.swift
//  MyApp
//
//  Created by Ava Sadasivan on 3/26/23.
//

import Foundation
import FirebaseFirestoreSwift

struct SQL_Project: Identifiable, Codable, Hashable {
    
    @DocumentID var id: String?
    
    var Title: String
    var Category: String
    var Subcategory: String
    var Title_URL: String
    var Description: String
    var Materials: [String]
    //let Percent_Owned: Int
    //let Number_Materials_Owned: Int
    //var numberMaterialsOwned: Int
    //var percentOwned: Int
    
    
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SQL_Project, rhs: SQL_Project) -> Bool {
        return lhs.id == rhs.id
    }
    
}
