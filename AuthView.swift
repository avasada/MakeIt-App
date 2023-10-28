import SwiftUI
import SQLite

struct AuthView: SwiftUI.View {
    
    //@State private var selectedTab: Tab = .lightbulb
    
    var database: Connection!
    
    let projectsTable = Table("SQLprojects")
    let id = Expression<Int>("id")
    let title = Expression<String>("title")
    let category = Expression<String>("category")
    
    @StateObject var viewModel = AuthViewModel()

    var body: some SwiftUI.View {
        
        if viewModel.user != nil  {
            MainTabView()
        } else {
            NavigationView {
                SignInForm(viewModel: viewModel.makeSignInViewModel()) {
                    NavigationLink("Create Account", destination: CreateAccountForm(viewModel: viewModel.makeCreateAccountViewModel()))
                }
            }
        }
    }
    
    /*
    //FOR MAKING SQL TABL
    mutating func getDocumentDirectory() {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("SQLprojects").appendingPathExtension("sqlite3")
            let database = try Connection(fileUrl.path)
            self.database = database
        } catch {
            print(error)
        }
    }
    
    //FOR MAKING SQL TABL
    func createTable() {
        print("Create Table Tapped")
        
        let createTable = self.projectsTable.create { table in
            table.column(self.id, primaryKey: true)
            table.column(self.title)
            table.column(self.category)
        }
        
        do {
            try self.database.run(createTable)
            print("Created Table")
        } catch {
            print(error)
        }
    }
    
    //FOR MAKING SQL TABL
    func insertProject(title: String, category: String) {
        let insertProject = self.projectsTable.insert(self.title <- title, self.category <- category)
        
        do {
            try self.database.run(insertProject)
            print("INSERTED PROJECT")
        } catch {
            print(error)
        }
        
    }
    */
    
    
    
}

private extension AuthView {
    struct SignInForm<Footer: SwiftUI.View>: SwiftUI.View {
        @StateObject var viewModel: AuthViewModel.SignInViewModel
        @ViewBuilder let footer: () -> Footer
        
        var body: some SwiftUI.View {
            Form {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
                    .background(Color.white)
            } footer: {
                Button("Sign In", action: viewModel.submit)
                    .buttonStyle(.primary)
                footer()
                    .padding()
            }
            .alert("Cannot Sign In", error: $viewModel.error)
            .disabled(viewModel.isWorking)
            .onSubmit(viewModel.submit)
        }
    }
}

private extension AuthView {
    struct CreateAccountForm: SwiftUI.View {
        @StateObject var viewModel: AuthViewModel.CreateAccountViewModel
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some SwiftUI.View {
            Form {
                TextField("Name", text: $viewModel.name)
                    .textContentType(.name)
                    .textInputAutocapitalization(.words)
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
            } footer: {
                Button("Create Account", action: viewModel.submit)
                    .buttonStyle(.primary)
                Button("Sign In", action: dismiss.callAsFunction)
                    .padding()
            }
            .alert("Cannot Create Account", error: $viewModel.error)
            .disabled(viewModel.isWorking)
            .onSubmit(viewModel.submit)
        }
    }
}

private extension AuthView {
    struct Form<Fields: SwiftUI.View, Footer: SwiftUI.View>: SwiftUI.View {
        @ViewBuilder let fields: () -> Fields
        @ViewBuilder let footer: () -> Footer
        
        var body: some SwiftUI.View {
            VStack {
                Image("MakeIt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                Text("")
                Text("")
                fields()
                    .padding()
                    .background(Color.secondary.opacity(0.15))
                    .cornerRadius(10)
                footer()
            }
            .navigationBarHidden(true)
            .padding()
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        AuthView()
    }
}

