//
//  SceneDelegate.swift
//  RecipeApp
//
//  Created by Scott.L on 08/10/2020.
//  Copyright © 2020 Scott. All rights reserved.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        /// App Appearance
        UINavigationBar.appearance().barTintColor = UIColor(named: "backgroundColor")
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20),
                                                            .foregroundColor: UIColor.white]

        UITabBar.appearance().barTintColor = UIColor(named: "backgroundColor")
        UITableView.appearance().backgroundColor = .clear
        
        var rootViewController = UIViewController()
        
        guard let _ = Defaults.isFirstTimeUser else {
            Defaults.isFirstTimeUser = false
            do {
                try Auth.auth().signOut()
            } catch { }
            
            rootViewController = SignUpViewController()
            window?.rootViewController = rootViewController
            window?.makeKeyAndVisible()
            return}
        
        if Auth.auth().currentUser != nil {
            rootViewController = UINavigationController(rootViewController: RecipeListViewController())
        } else {
            rootViewController = SignUpViewController()
        }
        
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    


}

