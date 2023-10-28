import SwiftUI
import Combine
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth

struct MaterialsList: View {
    
    @EnvironmentObject var auth: AuthService
    @State var materialsByCategory: [String: [String]] = [:]
    @State var isLoading: Bool = false
    @State var errorMessage: String = ""
    @State private var categoryColor: Color = .green
    
    
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    List {
                        Image("toolbox_large")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding()
                        
                        ForEach(materialsByCategory.keys.sorted(), id: \.self) { category in
                            Section(header: Text(category).listRowBackground(getCategoryColor(for: category))) {
                                ForEach(materialsByCategory[category] ?? [], id: \.self) { material in
                                    HStack {
                                        Text(material)
                                    }
                                    .swipeActions {
                                        Button(action: {
                                            deleteMaterial(material)
                                        }) {
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                        }
                                        .tint(.red)
                                        .padding(.trailing, 20)
                                        .frame(width: 50, height: 50)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.red, lineWidth: 2))
                                        .transition(.move(edge: .trailing))
                                    }
                                }
                            }
                            .listRowBackground(getCategoryColor(for: category))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .navigationBarTitle("Materials List")
                    .navigationBarItems(trailing:
                        NavigationLink(destination: AddMaterials().onDisappear(perform: getList)) {
                            Text("Add Materials +")
                        }
                    )
                    if isLoading {
                        ProgressView()
                    }
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                    }
                    Spacer()
                }
            }
        }
        .background(Color.blue.ignoresSafeArea())
        .frame(height: UIScreen.main.bounds.height * 0.9)
        .padding(.top, 50)
        .onAppear {
            getList()
        }
    }

    
    func getCategoryColor(for category: String) -> Color {
        switch category {
            case "crafts":
                return Color(red: 242/255, green: 145/255, blue: 228/255, opacity: 0.25)
            case "electronics":
                return Color(red: 197/255, green: 100/255, blue: 245/255, opacity: 0.25)
            case "machine":
                return Color(red: 115/255, green: 221/255, blue: 245/255, opacity: 0.25)
            case "misc":
                return Color(red: 245/255, green: 233/255, blue: 100/255, opacity: 0.25)
            case "tools":
                return Color(red: 245/255, green: 136/255, blue: 100/255, opacity: 0.25)
            case "woodworking":
                return Color(red: 240/255, green: 164/255, blue: 77/255, opacity: 0.25)
            default:
                return .gray
        }
    }
    
    
    func createSection(for category: String) -> some View {
        let categoryColor = getCategoryColor(for: category)
        print(categoryColor)
        return Section(header:
            Text(category)
        ) {
            ForEach(materialsByCategory[category] ?? [], id: \.self) { material in
                HStack {
                    Text(material)
                }
                .listRowBackground(categoryColor)
            }
        }
    }
    
    
    func getList() {
        guard let userId = auth.user?.id else { return }
        
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
                
                let listCollectionRef = document.reference.collection("List")
                listCollectionRef.getDocuments { (listSnapshot, error) in
                    if let error = error {
                        print("Error getting list collection: \(error.localizedDescription)")
                    } else {
                        if let documents = listSnapshot?.documents {
                            var materialsByCategory: [String: [String]] = [:]
                            for document in documents {
                                let data = document.data()
                                let name = data["name"] as? String ?? ""
                                let category = data["category"] as? String ?? "Uncategorized"
                                if materialsByCategory[category] == nil {
                                    materialsByCategory[category] = [name]
                                } else {
                                    materialsByCategory[category]!.append(name)
                                }
                            }
                            self.materialsByCategory = materialsByCategory
                        } else {
                            print("List collection exists but is empty")
                        }
                    }
                }
            }
        }
    }
    
    
    func deleteMaterial(_ material: String) {
        guard let userId = auth.user?.id else { return }
        
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
                
                let listCollectionRef = document.reference.collection("List")
                let materialDocumentQuery = listCollectionRef.whereField("name", isEqualTo: material)
                
                materialDocumentQuery.getDocuments { (materialSnapshot, error) in
                    if let error = error {
                        print("Error getting material document: \(error.localizedDescription)")
                    } else {
                        guard let materialDocument = materialSnapshot?.documents.first else {
                            print("Material document not found")
                            return
                        }
                        
                        materialDocument.reference.delete { (error) in
                            if let error = error {
                                print("Error deleting material: \(error.localizedDescription)")
                            } else {
                                print("Material deleted successfully")
                                // Remove the deleted material from the local state variable
                               self.materialsByCategory = self.materialsByCategory.mapValues { materials in
                                   materials.filter { $0 != material }
                               }
                               
                               // Reload the list view to reflect the changes
                               self.getList()
                            }
                        }
                    }
                }
            }
        }
    }
}
