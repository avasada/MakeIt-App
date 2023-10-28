import SwiftUI
import Firebase

@main
struct MyAppApp: App {
    
    
    init() {
        FirebaseApp.configure()
        //UITabBar.appearance().barTintColor = UIColor(red: 104/255, green: 188/255, blue: 195/255, alpha: 1.0)
        //UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }
    
    var body: some Scene {
        WindowGroup {
            AuthView()
        }
    }
}
