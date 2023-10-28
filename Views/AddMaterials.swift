import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import SQLite

struct AddMaterials: SwiftUI.View {
    
    @FirestoreQuery(collectionPath: "materialsList") private var materialsList: [MaterialItem]
    @EnvironmentObject var auth: AuthService
    @State private var materialFound: [String: Bool] = [:]
    @State private var searchQuery = ""
    private var database = try! Connection("\(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])/SQLProjectsDatabase.sqlite")

    private var materialsByCategory: [String: [MaterialItem]] {
        let filteredMaterials = materialsList.filter { material in
            searchQuery.isEmpty || material.name.localizedCaseInsensitiveContains(searchQuery)
        }
        return Dictionary(grouping: filteredMaterials) { $0.category }
    }

    var body: some SwiftUI.View {
        NavigationView {
            List {
                Section() {
                    TextField("Search materials", text: $searchQuery)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255))
                .padding(.top, 10)
                .padding(.bottom, 10)
                ForEach(materialsByCategory.keys.sorted(), id: \.self) { category in
                    Section(header: Text(category)) {
                        ForEach(materialsByCategory[category]!) { material in
                            MaterialRow(material: material)
                                .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255))
                                
                        }
                    }
                }
            }
            .onAppear {
                materialFound = [:]
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Add Materials")
    }
    
    
}


struct MaterialRow: SwiftUI.View {
    
    private var database: Connection!
    
    let projectsTable = Table("SQL_ProjectsTable")
    let title = Expression<String>("title")
    let category = Expression<String>("category")
    let subcategory = Expression<String>("subcategory")
    let link = Expression<String>("link")
    let description = Expression<String>("description")
    let materials = Expression<String>("materials")
    let percentOwned = Expression<Int>("percentOwned")
    let numberMaterialsOwned = Expression<Int>("numberMaterialsOwned")

    
    @EnvironmentObject var auth: AuthService
    let material: MaterialItem
    @State private var isMaterialInList = false
    @State private var isToggled = false
    
    // Initialize the view and obtain the database connection
    init(material: MaterialItem) {
        self.material = material
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent("SQLProjectsDatabase").appendingPathExtension("sqlite")
            let database = try Connection(fileURL.path)
            self.database = database
        } catch {
            print(error)
        }
    }
        

    var body: some SwiftUI.View {
        HStack {
            Text(material.name)
            Spacer()
            Button(action: {
                isMaterialInList.toggle()
                if isMaterialInList {
                    addMaterialToList(material)
                } else {
                    addMaterialToList(material)
                }
            }) {
                Label(
                    title: { Text(isMaterialInList ? "" : "") }, //find a way to get rid of this...
                    icon: { Image(systemName: isMaterialInList ? "checkmark.circle.fill" : "circle") }
                )
                .foregroundColor(isMaterialInList ? .green : .gray)
            }
        }
        .onAppear {
            checkMaterialInList(material)
        }
    }
    
    mutating func getDatabaseConnection() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent("SQLProjectsDatabase").appendingPathExtension("sqlite")
            let database = try Connection(fileURL.path)
            self.database = database
        } catch {
            print(error)
        }
    }
    
    func checkMaterialInList(_ material: MaterialItem) {
        guard let userId = auth.user?.id else { return }
        
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("Users")
        
        let query = usersCollectionRef.whereField("id", isEqualTo: userId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
            } else {
                guard let document = querySnapshot?.documents.first else { return }
                
                let listCollectionRef = document.reference.collection("List")
                listCollectionRef.getDocuments { (listSnapshot, error) in
                    if let error = error {
                        print("Error getting list collection: \(error.localizedDescription)")
                    } else {
                        if let count = listSnapshot?.count {
                            if count > 0 {
                                for document in listSnapshot!.documents {
                                    if let name = document.data()["name"] as? String {
                                        if name == material.name {
                                            isMaterialInList = true
                                            return
                                        }
                                    }
                                }
                                isMaterialInList = false
                            } else {
                                isMaterialInList = false
                            }
                        } else {
                            isMaterialInList = false
                        }
                    }
                }
            }
        }
    }
    
    func updateSQLtable(userMaterialList: [String]) {
        do {
            let projectsTable = Table("SQL_ProjectsTable")
            let title = Expression<String>("title")
            let materials = Expression<String>("materials")
            let percentOwned = Expression<Int>("percentOwned")
            let numberMaterialsOwned = Expression<Int>("numberMaterialsOwned")
            
            for project in try database.prepare(projectsTable) {
                let projectMaterials = project[materials].components(separatedBy: ",")
                var count = 0
                
                for material in userMaterialList {
                    for projectMaterial in projectMaterials {
                        if projectMaterial.contains(material) {
                            count += 1
                            break
                        }
                    }
                }
                
                let percent = Int(Double(count)/Double(projectMaterials.count) * 100)

                            
                let updateProject = projectsTable.filter(title == project[title])
                try database.run(updateProject.update(numberMaterialsOwned <- count, percentOwned <- percent))
                
            }
        } catch {
            print(error)
        }
    }

    
    func addMaterialToList(_ material: MaterialItem) {
        guard let userId = auth.user?.id else { return }
        print(userId)
        var userMaterialList = [String]()
        
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("Users")
        
        let query = usersCollectionRef.whereField("id", isEqualTo: userId)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting user document: \(error.localizedDescription)")
            } else {
                guard let document = querySnapshot?.documents.first else {
                    print("User document not found")
                    return
                }
                let data = document.data()
                if let name = data["name"] as? String {
                    print("User's name is \(name)")
                } else {
                    print("Name field not found in user document")
                }
                
                //finding List collection and making sure its there
                let listCollectionRef = document.reference.collection("List")
                listCollectionRef.getDocuments { (listSnapshot, error) in
                    if let error = error {
                        print("Error getting list collection: \(error.localizedDescription)")
                    } else {
                        if let count = querySnapshot?.count {
                            if count > 0 {
                                print("List found with \(count) items")
                                
                                //populate usersList
                                for document in listSnapshot!.documents {
                                    if let name = document.data()["name"] as? String {
                                        userMaterialList.append(name)
                                    }
                                }
                                
                                
                                //add the material!!
                                var materialFound = false
                                // first, delete the document if it exists
                                for document in listSnapshot!.documents {
                                    if let name = document.data()["name"] as? String {
                                        
                                        if name == material.name {
                                            // Material already exists in List collection, delete it
                                            document.reference.delete()
                                            print("Deleted \(material.name) from List collection")
                                            materialFound = true
                                            // delete form usersMaterialsList
                                            // Find the index of the element to be removed
                                            if let index = userMaterialList.firstIndex(of: name) {
                                                // Remove the element at the found index
                                                userMaterialList.remove(at: index)
                                            }
                                            //update SQL table
                                            updateSQLtable(userMaterialList: userMaterialList)
                                        }
                                    } else {
                                        print("Name field not found in document")
                                    }
                                }
                                print("userMaterialList: \(userMaterialList)")
                                // then, create a new document
                                if !materialFound {
                                    let newDocumentRef = listCollectionRef.document()
                                    newDocumentRef.setData(["name": material.name, "quantity": material.quantity, "category": material.category])
                                    print("Added \(material.name) to List collection")
                                    userMaterialList.append(material.name)
                                    //update SQL table
                                    updateSQLtable(userMaterialList: userMaterialList)
                                    }
                                } else {
                                    print("List collection exists but is empty")
                                }
                        } else {
                            print("List collection does not exist")
                                }
                            }
                        }
                    }
                }
            }
}


struct AddMaterials_Previews: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        AddMaterials()
    }
}

