import SwiftUI
import SQLite
import FirebaseFirestore
import FirebaseAuth

struct ProjectDetailView2: SwiftUI.View {
    
    let project: SQL_Project
    var database: Connection!
    let projectsTable = Table("SQL_ProjectsTable")
    
    @State private var highlightedRequiredMaterialsNames = [String]()
    @State private var highlightedMaterialsNames = [String]()
    @State private var isFavorite = false
    
    @State private var requiredMaterialsNames = [String]()
    @State private var userMaterials = [String]()
    @State private var showingBottomSheet = false
    
    init(project: SQL_Project) {
        self.project = project
        getDatabaseConnection()
    }

    
    var body: some SwiftUI.View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(project.Title)
                    .font(.custom("HelveticaNeue-Bold", size: 24))
                    .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                Text(project.Category)
                    .font(.custom("HelveticaNeue-Medium", size: 18))
                    .foregroundColor(Color(red: 104/255, green: 188/255, blue: 195/255, opacity: 1))
                Button(action: {
                    guard let url = URL(string: project.Title_URL) else { return }
                    UIApplication.shared.open(url)
                }) {
                    Text("Go to full tutorial")
                        .font(.custom("HelveticaNeue-Medium", size: 14))
                        .foregroundColor(Color(red: 82/255, green: 170/255, blue: 178/255, opacity: 1))
                        .underline()
                        .padding(.bottom, 8)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(getCategoryColor(category: project.Category))
                    Text(project.Description)
                        .font(.body)
                        .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                        .lineLimit(nil)
                        //.padding(.bottom, 16)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Required Materials:")
                        .font(.custom("HelveticaNeue-Bold", size: 15))
                        .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                        .padding(.top, 16)
                    ForEach(requiredMaterialsNames, id: \.self) { name in
                        let isHighlighted = highlightedMaterialsNames.contains(name)
                        let recommendation = getMaterialRecommendation(name)
                        HStack {
                            Text(name)
                                .font(.body)
                                .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 10)
                                .background(isHighlighted ? Color.green.opacity(0.3) : Color.clear)
                                .cornerRadius(4)
                            Spacer()
                            if !recommendation.isEmpty {
                                VStack {
                                    Button(action: {
                                        showingBottomSheet.toggle()
                                    }) {
                                        Text("💡")
                                            .font(.system(size: 30)) // Increase the font size to make the icon bigger
                                    }
                                }
                                .sheet(isPresented: $showingBottomSheet) {
                                    VStack {
                                        Image("smart_materials")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 250, height: 250)
                                        Text(recommendation)
                                            .font(.custom("HelveticaNeue-Medium", size: 18))
                                            .padding(.horizontal, 15)
                                            .padding(.top, -30)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .presentationDetents([.height(450)])
                                    }
                                    .background(
                                        Color(red: 148/255, green: 209/255, blue: 150/255, opacity: 0.5)
                                            .edgesIgnoringSafeArea(.all)
                                    )
                                }
                                
                                
                                /*
                                Button(action: {
                                    showingBottomSheet.toggle()
                                 
                                    let recommendation = getMaterialRecommendation(name)
                                    if !recommendation.isEmpty {
                                        let alert = UIAlertController(title: "Recommendation", message: recommendation, preferredStyle: .alert)
                                        
                                        alert.addAction(UIAlertAction(title: "OK", style: .default))
                                        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
                                    }
                                }) {
                                    Text("💡")
                                        .font(.system(size: 30))
                                        .foregroundColor(.blue)
                                }
                                */
                                /*
                                .sheet(isPresented: $showingBottomSheet) {
                                    Text("Cool bottom sheet")
                                }
                                 */
                                /*
                                .sheet(isPresented: $showingBottomSheet) {
                                    BottomSheetView()
                                        .presentationDetents([.fraction(0.2), .medium])
                                        .presentationDetents(.visible)
                                }
                                 */
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationBarTitle(Text(""), displayMode: .inline)
            .onAppear {
                fetchRequiredMaterialsNames()
                fetchUserMaterials()
                checkFavorite()
            }
        }
        .navigationBarItems(trailing: Button(action: {
            toggleFavorite()
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
        })
    }
    
    // for background box of description and category text color
    func getCategoryColor(category: String) -> Color {
        switch category {
        case "Circuits":
            return Color(red: 255/255, green: 204/255, blue: 177/255)
        case "Living":
            return Color(red: 225/255, green: 241/255, blue: 173/255)
        case "Workshop":
            return Color(red: 165/255, green: 230/255, blue: 248/255)
        case "Craft":
            return Color(red: 244/255, green: 200/255, blue: 225/255)
        case "Teachers":
            return Color(red: 195/255, green: 247/255, blue: 201/255)
        default:
            return Color.gray // Default color if the category doesn't match any of the specified ones
        }
    }

    
    private func getMaterialRecommendation(_ materialName: String) -> String {
        let recommendations: [String: String] = [
            "wood": "Use wooden crates or boxes from shipping or storage",
            "wire": "Repurpose wire hangers or collect wires from old electronics",
            "led": "Try salvaging LEDs from old electronics, such as broken toys or appliances. Alternatively, you can create your own LED lights using copper wire, a small battery, and a light-emitting diode. There are many tutorials online for this",
            "fabric": "Look for fabric scraps at thrift stores or garage sales. Old clothes can also be repurposed for fabric. You can also try using household items such as pillowcases or sheets",
            "stick": "Collect sticks from your backyard or local park. You can also use wooden skewers or toothpicks as a substitute",
            "pvc": "Try using cardboard tubes or even rolled up newspaper",
            "duct tape": "Duct tape can be expensive, but there are cheaper alternatives such as masking tape or even electrical tape. You can also try using paper tape or washi tape for a more decorative effect",
            "microphone": "If you don't have access to a microphone, you can use the microphone on your phone or computer. Alternatively, you can create a simple microphone using a piezo-electric element and a .25 inch jack",
            "push button": "You can salvage push buttons from old electronics or toys. Alternatively, you can create your own push buttons using metal foil and cardboard",
            "spring": "Old pens and toys can provide springs. You can also create your own springs using wire and a cylindrical object such as a pen or pencil",
            "clay": "Try creating your own clay using flour, salt, and water",
            "chain": "You can use paper clips or even twist ties as a substitute for chain",
            "servos": "If you don't have access to servos, you can try using small motors salvaged from toys or other electronics. Alternatively, you can create your own servo using a potentiometer and a small motor"
        ]
        for (key, value) in recommendations {
            if materialName.localizedCaseInsensitiveContains(key) {
                return value
            }
        }
        return ""
    }


    
    private func checkHighlightedMaterials() {
        for name in requiredMaterialsNames {
            if userMaterials.contains(name) {
                highlightedMaterialsNames.append(name)
            } else {
                for material in userMaterials {
                    if name.localizedCaseInsensitiveContains(material) {
                        highlightedMaterialsNames.append(name)
                        break
                    }
                }
            }
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
        

    private func fetchRequiredMaterialsNames() {
        requiredMaterialsNames.removeAll()
        do {
            let materialsColumn = Expression<String?>("Materials")
            let query = projectsTable.filter(Expression<String>("Title") == project.Title)
            let materials = try database.pluck(query.select(materialsColumn))
            if let materialsString = materials?[materialsColumn] {
                requiredMaterialsNames = materialsString.components(separatedBy: ", ")
            }
        } catch {
            print("Error fetching required materials: \(error.localizedDescription)")
        }
    }

    
    private func fetchUserMaterials() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("Users").whereField("id", isEqualTo: userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting user materials list: \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("No user materials found")
                    return
                }
                for document in documents {
                    print("DocumentID: \(document.documentID)")
                    let userCollectionRef = db.collection("Users").document(document.documentID).collection("List")
                    userCollectionRef.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting user materials list: \(error.localizedDescription)")
                        } else {
                            guard let documents = querySnapshot?.documents else {
                                print("No user materials found")
                                return
                            }
                            let userMaterials = documents.compactMap { (document) -> String? in
                                let data = document.data()
                                let name = data["name"] as? String
                                let id = document.documentID
                                print("DocumentID: \(id), name: \(name ?? "")")
                                return name
                            }
                            self.userMaterials = userMaterials
                            self.checkHighlightedMaterials()
                        }
                    }
                }
            }
        }
    }

    private func checkFavorite() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userDocRef = db.collection("Users").document(user.uid)
        print("USER: \(user.uid)")
        
        let favoritesSubcollectionRef = userDocRef.collection("favorites")
        let projectId = project.Title
        
        // Check if project is already in favorites subcollection
        favoritesSubcollectionRef.document(projectId).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
            } else {
                if let document = documentSnapshot, document.exists {
                    self.isFavorite = true
                } else {
                    self.isFavorite = false
                }
            }
        }
    }
    
    private func toggleFavorite() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let userFavoriteDocRef = db.collection("Users").document(user.uid).collection("favorites").document(project.Title)

        if isFavorite {
            // Remove project from favorites subcollection
            userFavoriteDocRef.delete { error in
                if let error = error {
                    print("Error removing project from favorites: \(error.localizedDescription)")
                } else {
                    self.isFavorite = false
                    print("Removed from favorites")
                }
            }
        } else {
            // Add project to favorites subcollection
            let data: [String: Any] = ["projectTitle": project.Title]
            userFavoriteDocRef.setData(data) { error in
                if let error = error {
                    print("Error adding project to favorites: \(error.localizedDescription)")
                } else {
                    self.isFavorite = true
                    print("Added to favorites")
                }
            }
        }
    }
    
    private func printListNames() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        let usersCollectionRef = db.collection("Users")
        let query = usersCollectionRef.whereField("id", isEqualTo: user.uid)

        var listNames: [String] = []

        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents else { return }
                for document in documents {
                    let listRef = document.reference.collection("List")

                    // Retrieve all documents in the "List" subcollection and append their "name" field value to the listNames array
                    listRef.getDocuments { (querySnapshot, error) in
                        if let error = error {
                            print("Error getting documents: \(error.localizedDescription)")
                        } else {
                            guard let documents = querySnapshot?.documents else { return }
                            for document in documents {
                                let listName = document.get("name") as? String ?? "List name not found"
                                listNames.append(listName)
                            }
                        }
                        print("List names: \(listNames)")
                    }
                }
            }
        }
    }



}



struct ProjectDetailView2_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        NavigationView {
            ProjectDetailView2(project: SQL_Project(
                Title: "title",
                Category: "category",
                Subcategory: "subcategory",
                Title_URL: "url",
                Description: "description",
                Materials: ["material1", "material2"]
            ))
        }
    }
}
