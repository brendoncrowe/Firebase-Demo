//
//  UIViewController+Navigation.swift
//  Firebase-Demo
//
//  Created by Brendon Crowe on 4/10/23.
//  Copyright © 2023 Brendon Crowe. All rights reserved.
//

import UIKit

// MARK: Extension used to help with app navigation 

extension UIViewController {
    
    private static func resetWindow(with rootViewController: UIViewController) {
        // the below code gets access to the window property in the sceneDelegate
        guard let scene = UIApplication.shared.connectedScenes.first, let sceneDelegate = scene.delegate as? SceneDelegate, let window = sceneDelegate.window else {
            fatalError("could not reset window rootViewController")
        }
        window.rootViewController = rootViewController
    }
    
    
    public static func showViewController(storyBoardName: String, viewControllerID: String) {
        
        let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
        let newVC = storyboard.instantiateViewController(identifier: viewControllerID)
        
        resetWindow(with: newVC)
        
    }
    
}
