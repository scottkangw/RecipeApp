//
//  Defaults.swift
//  RecipeApp
//
//  Created by Scott.L on 17/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import Foundation

final class Defaults {
    
    fileprivate enum Key: String {
        case firstTimeUser
        case firstRecipe
        
        static let all: [Key] = [
            .firstTimeUser, .firstRecipe
        ]
    }
    
    static var isFirstTimeUser: Bool? {
        get {
            return UserDefaults.standard.value(forKey: Key.firstTimeUser.rawValue) as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.firstTimeUser.rawValue)
        }
    }
    
    static var isFirstRecipe: Bool? {
        get {
            return UserDefaults.standard.value(forKey: Key.firstRecipe.rawValue) as? Bool
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.firstRecipe.rawValue)
        }
    }

    
    class func synchronize() {
        UserDefaults.standard.synchronize()
    }
    
    class func clearAll() {
        let defaults = UserDefaults.standard
        for key in Key.all {
            defaults.removeObject(forKey: key.rawValue)
        }
        defaults.synchronize()
    }
    
}
