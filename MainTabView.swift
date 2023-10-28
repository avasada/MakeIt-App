import SwiftUI


enum Tab: String, CaseIterable {
    case doc
    case magnifyingglass
    case lightbulb
    case person
}


struct CustomTabBar: View {
    
    //let authService = AuthService()
    
    @Binding var selectedTab: Tab
    private var fillImage: String {
        if selectedTab == .magnifyingglass {
            return "magnifyingglass.circle.fill"
        } else {
            return selectedTab.rawValue + ".fill"
        }
    }
        
    private var tabColor: Color {
        switch selectedTab {
        case .doc:
            return .purple
        case .magnifyingglass:
            return Color(red: 250/255, green: 122/255, blue: 239/255)
        case .lightbulb:
            return .yellow
        case .person:
            return .orange
        }
    }
    var body: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.rawValue) { tab in
                    Spacer()
                    Image(systemName: selectedTab == tab ? fillImage : tab.rawValue)
                        .scaleEffect(selectedTab == tab ? 1.25 : 1.0)
                        .foregroundColor(selectedTab == tab ? tabColor : .gray)
                        .font(.system(size: 22))
                        .onTapGesture {
                            withAnimation(.easeIn(duration: 0.1)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(width: nil, height: 49)
            .background(.thinMaterial)
            .cornerRadius(10)
            .padding()
            .padding(.bottom, -20)
        }
    }
}

@MainActor
struct MainTabView: View {
    let authService = AuthService()
    //@EnvironmentObject private var authService: AuthService
    
    @State private var selectedTab: Tab = .lightbulb
     
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                MaterialsList()
                    .tabItem {
                        //Image(systemName: selectedTab == .list ? "list.bullet.rectangle.fill" : "list.bullet.rectangle") // Updated the system name
                        //Text(Tab.list.rawValue.capitalized)
                        Image(systemName: selectedTab == .doc ? "doc.fill" : Tab.doc.rawValue)
                        Text("\(Tab.doc.rawValue.capitalized)")
                    }
                    .tag(Tab.doc)
                
                SearchView()
                    .tabItem {
                        Image(systemName: selectedTab == .magnifyingglass ? "magnifyingglass.circle.fill" : Tab.magnifyingglass.rawValue)
                        Text("\(Tab.magnifyingglass.rawValue.capitalized)")
                    }
                    .tag(Tab.magnifyingglass)
                
                LearnView()
                    .tabItem {
                        Image(systemName: selectedTab == .lightbulb ? "lightbulb.fill" : Tab.lightbulb.rawValue)
                        Text("\(Tab.lightbulb.rawValue.capitalized)")
                    }
                    .tag(Tab.lightbulb)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: selectedTab == .person ? "person.fill" : Tab.person.rawValue)
                        Text("\(Tab.person.rawValue.capitalized)")
                    }
                    .tag(Tab.person)
            }
            .environmentObject(authService)
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
    
}


/*
@MainActor
struct MainTabView: View {
    
    let authService = AuthService()
    
    init() {
    }
    
    /*
    var image : String
    @Binding var selectedTab: String
    
    var body: some View {
        
        ZStack(alignmnet: Alignment(horizontal: .center, vertical: .bottom)) {
            
            MaterialsList()
            
            HStack(spacing: 0) {
                ForEach(tabs, id: \.self){image in
                    
                    TabButton(image: image, selectedtab: $selectedTab)
                    
                    // equal spacing
                    
                    if image != tabs.last {
                        Spacer(minLength: 0)
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(vertical, 5)
            .background(Color.white)
            .clipShape(
        }
    }
                */
    
    var body: some View {
        TabView {
            /*
            Group {
                MaterialsList()
                //.background(Color.white) 
            }
            .tabItem {
                VStack {
                    Text("🧰")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                    Text("Materials")
                }
            }
             */
            MaterialsList()
                .background(Color.white)
                .tabItem {
                    Label("Materials List", systemImage: "list.dash")
                        .imageScale(.large)
                }
            SearchView()
                .background(Color.white)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .imageScale(.large)
                }
            LearnView()
                .background(Color.white)
                .tabItem {
                    Label("Learn", systemImage: "lightbulb.fill")
                        .imageScale(.large)
                }
            ProfileView()
                .background(Color.white)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                        .imageScale(.large)
        
                }
        }
        .accentColor(Color(red: 58/255, green: 80/255, blue: 106/255, opacity: 1))
        .environmentObject(authService)
    }
    
    
    
}
*/
        
 /*
// tabs
//image names
var tabs = ["list.dash", "magnifyingglass", "lightbulb.fill", "person.fill"]

struct TabButton : View {
    
}
  */

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
