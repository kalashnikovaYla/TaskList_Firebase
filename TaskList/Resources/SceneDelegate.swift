//
//  SceneDelegate.swift
//  TaskList_Firebase
//
//  Created by sss on 11.01.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        let initialViewController  = InitialViewController()
        let navigationController = UINavigationController(rootViewController: initialViewController)
        navigationController.navigationBar.prefersLargeTitles = true 
        navigationController.navigationBar.barStyle = .black
        navigationController.navigationBar.tintColor = .white
        window?.rootViewController = navigationController
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
    }

    
}

