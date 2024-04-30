//
//  Utilities.swift
//  InspireSync
//
//  Created by Nivethikan Neethirasa on 2024-01-14.
//

import Foundation
import UIKit

final class Utilities{
    
    static let shared = Utilities()
    private init() {}
    
    
    @MainActor
    func topViewController(controller: UIViewController? = nil, windowScene: UIWindowScene? = nil) -> UIViewController? {
        var rootViewController: UIViewController?
        
        if let windowScene = windowScene {
            rootViewController = windowScene.windows.first?.rootViewController
        } else {
            if #available(iOS 13.0, *) {
                // Get the main window scene
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    rootViewController = scene.windows.first?.rootViewController
                }
            } else {
                rootViewController = UIApplication.shared.keyWindow?.rootViewController
            }
        }
        
        let controller = controller ?? rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }

}


