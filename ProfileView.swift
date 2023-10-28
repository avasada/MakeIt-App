import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth
import SQLite
import Foundation

struct ProfileView: SwiftUI.View {
    @StateObject var viewModel = ProfileViewModel()
    @EnvironmentObject var auth: AuthService
    
    let db = Firestore.firestore()
    
    var database: Connection!
    
    let projectsTable = Table("SQL_ProjectsTable")
    let title = Expression<String>("title")
    let category = Expression<String>("category")
    let subcategory = Expression<String>("subcategory")
    let link = Expression<String>("link")
    let description = Expression<String>("description")
    let materials = Expression<String>("materials")
    let percentOwned = Expression<Int>("percentOwned")
    let numberMaterialsOwned = Expression<Int>("numberMaterialsOwned")
    
    init() {
        getDocumentDirectory()
    }

    var body: some SwiftUI.View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(spacing: 5) {
                    Image("profile_2")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 175, height: 175)
                        .alignmentGuide(HorizontalAlignment.center) { d in
                            d[HorizontalAlignment.center]
                        }
                    /*
                    Text("Personal Information")
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 104/255, green: 188/255, blue: 195/255))
                     */
                        //Text("Name:")
                            //.fontWeight(.bold)
                    TextField("Name", text: $viewModel.name)
                        .background(Color.white)
                        .cornerRadius(10)
                        .multilineTextAlignment(.center)
                        .padding(.top, -20)
                    Button(action: {
                        try! Auth.auth().signOut()
                    }, label: {
                        Text("Sign Out")
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                            .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255))
                    })
                    .padding(.horizontal, 20)
                    
                    
                }
                .padding(.horizontal, 20)
        
                VStack(alignment: .leading, spacing: 10) {
                    Text("Favorites")
                        .fontWeight(.bold)
                        .font(.system(size: 28))
                        //.foregroundColor(Color(red: 104/255, green: 188/255, blue: 195/255))
                    
                    if viewModel.favoriteProjects.isEmpty {
                        Text("You have no favorite projects.")
                    } else {
                        ScrollView() {
                            ForEach(viewModel.favoriteProjects, id: \.self) { projectTitle in
                                NavigationLink(destination: ProjectDetailView2(project: getProject(withTitle: projectTitle)!)) {
                                    HStack {
                                        Text(projectTitle)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 58/255, green: 80/255, blue: 106/255))
                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(red: 191/255, green: 232/255, blue: 229/255, opacity: 0.8))
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                Spacer()
            }
            .accentColor(Color(red: 58/255, green: 80/255, blue: 106/255))
            .onSubmit {
                viewModel.updateProfile()
            }
            .navigationBarTitle("Profile")
        }
        .onAppear {
            guard let user = Auth.auth().currentUser else { return }
            
            let favoritesDocRef = db.collection("Users").document(user.uid).collection("favorites")
            favoritesDocRef.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                viewModel.favoriteProjects = snapshot.documents.compactMap { document -> String? in
                    let data = document.data()
                    return data["projectTitle"] as? String
                }
            }
            do {
                if let fileURL = Bundle.main.url(forResource: "FormattedProjects2", withExtension: "json") {
                    print("Found file at \(fileURL)")
                    let jsonData = try Data(contentsOf: fileURL)
                    print("Read data from file")
                    print(jsonData)
                    let projects = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [[String: Any]]
                    print("Decoded projects from data")
                    for project in projects {
                        self.insertProject(project)
                    }
                    print("Inserted projects into database")
                } else {
                    print("File not found")
                }
            } catch {
                print("Error adding projects to database: \(error.localizedDescription)")
                
            }
        }
    }

    func getProject(withTitle title: String) -> SQL_Project? {
        do {
            let project = try database.pluck(projectsTable.filter(self.title == title))
            if let project = project {
                let materials = project[self.materials].components(separatedBy: ",")
                return SQL_Project(
                    Title: project[self.title],
                    Category: project[self.category],
                    Subcategory: project[self.subcategory],
                    Title_URL: project[self.link],
                    Description: project[self.description],
                    Materials: materials
                )
            } else {
                return nil
            }
        } catch {
            fatalError("Error retrieving project: \(error.localizedDescription)")
        }
    }

    
    // GET DOCUMENT DIRECTORY
    mutating func getDocumentDirectory() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("SQLProjectsDatabase").appendingPathExtension("sqlite")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
    }

    
    // CREATE TABLE
    func createTable() {
        print("Create Table Tapped")
        
        let createTable = self.projectsTable.create { table in
            table.column(self.title, primaryKey: true)
            table.column(self.category)
            table.column(self.subcategory)
            table.column(self.link)
            table.column(self.description)
            table.column(self.materials)
            table.column(self.percentOwned)
            table.column(self.numberMaterialsOwned)
        }
        
        do {
            try self.database.run(createTable)
            print("Created Table")
        } catch {
            print(error)
        }
    }
    
    //INSERT PROJECTS
    func insertProject(_ project: [String: Any]) {
        

        guard let title = project["Title"] as? String else {
            print("Invalid project data - missing or invalid Title")
            return
        }

        guard let category = project["Category"] as? String else {
            print("Invalid project data - missing or invalid Category")
            return
        }

        guard let subcategory = project["Subcategory"] as? String else {
            print("Invalid project data - missing or invalid Subcategory")
            return
        }

        guard let link = project["Title_URL"] as? String else {
            print("Invalid project data - missing or invalid Title_URL")
            return
        }

        guard let description = project["Description"] as? String else {
            print("Invalid project data - missing or invalid Description")
            return
        }

        guard let materialsArray = project["Materials"] as? [String] else {
            print("project[\"Materials\"]: \(project["Materials"] ?? "nil")")
            print("Invalid project data - missing or invalid Materials array")
            return
        }
        
        
        let materials = materialsArray.joined(separator: ", ")
        let insertProject = self.projectsTable.insert(self.title <- title, self.category <- category, self.subcategory <- subcategory, self.link <- link, self.description <- description, self.materials <- materials, self.percentOwned <- 0, self.numberMaterialsOwned <- 0)

            
        print("\(self.title) inserted")
            
        
        do {
            try self.database.run(insertProject)
            print("Inserted Project: \(title)")
        } catch {
            print(error)
        }
    }


    
    // LIST PROJECTS
    func listProjects() {
        print("LIST TAPPED")
        
        do {
            let projects = try self.database.prepare(self.projectsTable)
            for project in projects {
                let title = project[self.title]
                let category = project[self.category]
                let subcategory = project[self.subcategory]
                let link = project[self.link]
                let description = project[self.description]
                let materials = project[self.materials]
                let percentOwned = project[self.percentOwned]
                let numberMaterialsOwned = project[self.numberMaterialsOwned]
                
                print("Title: \(title), Category: \(category), Subcategory: \(subcategory), Link: \(link), Description: \(description), Materials: \(materials), Percent Owned: \(percentOwned), Number of Materials Owned: \(numberMaterialsOwned)")
            }
        } catch {
            print(error)
        }
    }
    
    // DELETE PROJECT
    func deleteProject(projectTitle: String) {
        print("DELETE TAPPED")
        
        let project = self.projectsTable.filter(self.title == projectTitle)
        let deleteProject = project.delete()
        do {
            try self.database.run(deleteProject)
        } catch {
            print(error)
        }
    }
    
    func accessFavoritesProject() {
        
    }

}

class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var favoriteProjects = [String]()

    let db = Firestore.firestore()


    private let userDocRef = Firestore.firestore().collection("Users").document(Auth.auth().currentUser!.uid)

    private var userListener: ListenerRegistration?

    init() {
        userListener = userDocRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let snapshot = snapshot, snapshot.exists else {
                return
            }

            let data = snapshot.data()!
            self.name = data["name"] as! String
            if let email = data["email"] as? String {
                self.email = email
            }
        }
    }

    deinit {
        userListener?.remove()
    }

    func updateProfile() {
        let data = ["name": name, "email": email] as [String : Any]
        userDocRef.updateData(data)
    }
    
}

