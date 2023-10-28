//
//  AuthService.swift
//  MyApp
//
//  Created by Ava Sadasivan on 1/24/23.
//

import SwiftUI
import Firebase //I changed FirebaseAuth to Firebase
import FirebaseFirestore

@MainActor
class AuthService: ObservableObject {
    //@Published var isAuthenticated = false
    @Published var user: User?
 
    private let auth = Auth.auth()
    private var listener: AuthStateDidChangeListenerHandle?
    
    func createAccount(name: String, email: String, password: String) async throws {
        let result = try await auth.createUser(withEmail: email, password: password)
        try await result.user.updateProfile(\.displayName, to: name)
        user?.name = name
        
        // Add user data to Firestore collection
        let db = Firestore.firestore()
        let userData = ["name": name, "id": result.user.uid, "email": email, "interests": []] as [String : Any]
        let userDocRef = db.collection("Users").document(result.user.uid)
        try await userDocRef.setData(userData)
        
        // Create a List subcollection within the user's document
        let listCollectionRef = userDocRef.collection("List")
        
        // Create a favorites subcollection within the user's document
        let favoritesCollectionRef = userDocRef.collection("favorites")
        
        
        
    }
    
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    

 
    init() {
        listener = auth.addStateDidChangeListener { [weak self] _, user in
            self?.user = user.map(User.init(from:))
        }
    }
    
}

//I changed FirebaseAuth.user to Firebase.user
private extension Firebase.User {
    func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
        var profileChangeRequest = createProfileChangeRequest()
        profileChangeRequest[keyPath: keyPath] = newValue
        try await profileChangeRequest.commitChanges()
    }
}

private extension User {
    init(from firebaseUser: Firebase.User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? ""
        self.list = []
        self.email = firebaseUser.email!
    }
}

