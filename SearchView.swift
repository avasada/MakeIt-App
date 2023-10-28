import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import FirebaseAuth
import SQLite
import Foundation
import Dispatch


struct SearchView: SwiftUI.View {
    
    @EnvironmentObject var auth: AuthService
    @State private var userMaterials = [String]()
    @State var sortedProjectsList = [SQL_Project]()
    @State private var isLoading = true
    
    var database: Connection!
    let projectsTable = Table("SQL_ProjectsTable")
    let title = Expression<String>("title")
    let category = Expression<String>("category")
    let subcategory = Expression<String>("subcategory")
    let link = Expression<String>("link")
    let description = Expression<String>("description")
    let materials = Expression<String>("materials")

    
    init() {
        getDatabaseConnection()
    }

    private var projectsList: [SQL_Project] {
        fetchProjectsFromSQL()
    }
    
    @State private var searchQuery = ""
    @State private var selectedProject: SQL_Project?
    @State private var selectedPercentage = 0
    
    private let percentageOptions = [0, 25, 50, 75, 100]
    
    
    private var filteredProjects: [SQL_Project] {
        let selectedMaterialsOwned = Double(selectedPercentage) / 100.0
        let userOwnedMaterials = Set(userMaterials)
        return projectsList.filter { project in
            let projectMaterials = Set(project.Materials)
            let userOwned = projectMaterials.filter { projectMaterial in
                userOwnedMaterials.contains { ownedMaterial in
                    projectMaterial.contains(ownedMaterial)
                }
            }.count
            let totalMaterials = projectMaterials.count
            let percentOwned = Double(userOwned) / Double(totalMaterials)
            print(percentOwned)
            return percentOwned >= selectedMaterialsOwned
        }
        .filter { project in
            searchQuery.isEmpty ||
                project.Title.localizedCaseInsensitiveContains(searchQuery)
        }
    }


    private var searchBar: SearchBar {
        SearchBar(text: $searchQuery)
    }
    
    var body: some SwiftUI.View {
        NavigationView {
            if isLoading {
                ProgressView()
                .foregroundColor(Color.blue)
                .padding(.top, 50)
                .animation(.easeInOut)
            } else {
                VStack {
                    searchBar
                        .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            
                            Button(action: {
                                // Handle circuits category selection
                            }) {
                                VStack {
                                    Image("craft_icon")
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                    Text("Crafts")
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                        .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                                }
                            }
                            
                            Button(action: {
                                // Handle circuits category selection
                            }) {
                                VStack {
                                    Image("circuits_icon") // Assuming "circuits" is the name of the PNG asset
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                    Text("Circuits")
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                        .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                                }
                            }
                            
                            Button(action: {
                                // Handle circuits category selection
                            }) {
                                VStack {
                                    Image("teacher_icon") // Assuming "circuits" is the name of the PNG asset
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                    Text("Teachers")
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                        .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                                }
                            }

                            Button(action: {
                                // Handle circuits category selection
                            }) {
                                VStack {
                                    Image("home_icon") // Assuming "circuits" is the name of the PNG asset
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                    Text("Living")
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                        .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                                }
                            }
                            
                            Button(action: {
                                // Handle circuits category selection
                            }) {
                                VStack {
                                    Image("tools_icon") // Assuming "circuits" is the name of the PNG asset
                                        .resizable()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                    Text("Workshop")
                                        .font(.custom("HelveticaNeue-Medium", size: 15))
                                        .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                    }
                    HStack {
                        Text("materials owned:")
                            .font(.headline)
                            .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                        Picker("", selection: $selectedPercentage) {
                            ForEach(percentageOptions, id: \.self) { percentage in
                                Text("\(percentage)%+").tag(percentage)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 150)
                    }
                    List(filteredProjects) { project in
                        VStack (alignment: .leading) {
                            NavigationLink(
                                destination: ProjectDetailView2(project: project),
                                tag: project,
                                selection: $selectedProject
                            ) {
                                SearchRow(project: project)
                                    .foregroundColor(.black) 
                            }
                        }
                        .listRowBackground(Color.white)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.white)
                    .animation(.spring())
                    .padding(.bottom, 50)
                    Spacer() // <-- Add this spacer at the bottom
                }
                .frame(height: UIScreen.main.bounds.height * 0.9)
                .padding(.top, 50)
            }
        }
        .navigationTitle("Search Projects")
        //.background(Color.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fetchUsersMaterials {
                    calcOrder()
                    isLoading = false
                }
            }
        }
    }
    
    

    func fetchProjectsFromSQL() -> [SQL_Project] {
       var projects = [SQL_Project]()
       do {
           for project in try database.prepare(projectsTable) {
               let newProject = SQL_Project(
                   id: project[title],
                   Title: project[title],
                   Category: project[category],
                   Subcategory: project[subcategory],
                   Title_URL: project[link],
                   Description: project[description],
                   Materials: project[materials].components(separatedBy: ",")
               )
               projects.append(newProject)
           }
       } catch {
           print(error)
       }
       return projects
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
    
    func fetchUsersMaterials(completion: @escaping () -> Void) {
        userMaterials = []
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
                    //print("User's name is \(name)")
                } else {
                    print("Name field not found in user document")
                }
                
                let listCollectionRef = document.reference.collection("List")
                listCollectionRef.getDocuments { (listSnapshot, error) in
                    if let error = error {
                        print("Error getting list collection: \(error.localizedDescription)")
                    } else {
                        if let documents = listSnapshot?.documents {
                            for document in documents {
                                let data = document.data()
                                let name = data["name"] as? String ?? ""
                                userMaterials.append(name)
                            }
                        } else {
                            print("List collection exists but is empty")
                        }
                    }
                    self.isLoading = false
                    completion()
                }
            }
        }
    }
        
    func calcOrder() {
        var projectsWithNumberOwned = [(project: SQL_Project, numberOwned: Int)]()
        
        projectsList.map { project in
            let projectMaterials = project.Materials
            let numberOwned = projectMaterials.filter(userMaterials.contains).count
            projectsWithNumberOwned.append((project, numberOwned))
        }
        
        sortedProjectsList = projectsWithNumberOwned.sorted { $0.numberOwned > $1.numberOwned }.map { $0.project }
        print(sortedProjectsList)
    }
    

}

struct SearchRow: SwiftUI.View {
    
    @EnvironmentObject var auth: AuthService
    
    var database: Connection!
    let projectsTable = Table("SQL_ProjectsTable")
    let title = Expression<String>("title")
    let materials = Expression<String>("materials")
    
    let project: SQL_Project
    
    @State private var requiredMaterialsNames = [String]()
    @State private var userMaterials = [String]()
    @State var numberMaterialsOwned = Int()
    @State var percentOwnedValue = Int()
    
    public init(project: SQL_Project) {
        self.project = project
        getDatabaseConnection()
    }
    
    var body: some SwiftUI.View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text(project.Title)
                    .font(.custom("HelveticaNeue-Bold", size: 17))
                    .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
                Text(project.Category)
                    .font(.custom("HelveticaNeue-Medium", size: 14))
                    .foregroundColor(Color(red: 104/255, green: 188/255, blue: 195/255, opacity: 1))
                Text("\(numberMaterialsOwned) / \(requiredMaterialsNames.count) Materials Owned")
                    .font(.custom("HelveticaNeue-Light", size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
            }
        }
        .padding(5)
        .background(Color.white)
        .cornerRadius(4)
        .onAppear{
            fetchUsersMaterials {
                calculateOwned()
            }
        }
    }
    
    
    func calculateOwned() {
        fetchRequiredMaterialsNames()
        var countOwnedMaterials = 0
        var ownedMaterials = [String]()
        
        for userMaterial in userMaterials {
            for requiredMaterial in requiredMaterialsNames where !ownedMaterials.contains(requiredMaterial) {
                if requiredMaterial.localizedCaseInsensitiveContains(userMaterial) {
                    countOwnedMaterials += 1
                    ownedMaterials.append(requiredMaterial)
                }
            }
        }
        let percentOwned = Double(countOwnedMaterials)/Double(requiredMaterialsNames.count) * 100
        numberMaterialsOwned = countOwnedMaterials
        percentOwnedValue = Int(percentOwned)
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
    
    func fetchRequiredMaterialsNames() {
        requiredMaterialsNames = []
        do {
            let projectQuery = projectsTable.filter(title == project.Title)
            let projectRow = try database.prepare(projectQuery)
            for project in projectRow {
                let materialsString = project[materials]
                let materials = materialsString.components(separatedBy: ",")
                requiredMaterialsNames.append(contentsOf: materials)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchUsersMaterials(completion: @escaping () -> Void) {
        userMaterials = []
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
                            for document in documents {
                                let data = document.data()
                                let name = data["name"] as? String ?? ""
                                userMaterials.append(name)
                            }
                        } else {
                            print("List collection exists but is empty")
                        }
                    }
                    completion()
                }
            }
        }
    }

}

struct SearchBar: SwiftUI.View {
    @SwiftUI.Binding var text: String

    var body: some SwiftUI.View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search", text: $text)
                .foregroundColor(.primary)
                .padding(8)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                })
                .padding(.trailing, 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}



struct SearchView_Previews: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        SearchView()
    }
}


