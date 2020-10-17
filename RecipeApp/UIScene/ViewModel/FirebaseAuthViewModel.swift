//
//  FirebaseAuthViewModel.swift
//  RecipeApp
//
//  Created by Scott.L on 17/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthViewModel {
    
    var isSuccessful: (() -> ())?
    var isFailed: (() -> ())?
    var checkSignUp: (() -> ())?
    var isSignOut: (() -> ())?
    
    
    
    func signUp(email: String, password: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            guard error == nil else { self.isFailed?(); return }
            self.isSuccessful?()
        }
    }
    
    func signIn(email: String, password: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            guard error == nil else { self.isFailed?(); return }
            self.isSuccessful?()
        }
        checkSignUp?()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isSignOut?()
        } catch {
        }
    }
    
}
