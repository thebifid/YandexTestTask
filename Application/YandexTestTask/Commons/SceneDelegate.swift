//
//  SceneDelegate.swift
//  YandexTestTask
//
//  Created by Vasiliy Matveev on 17.02.2021.
//

import AMScrollingNavbar
import Cartography
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = ScrollingNavigationController(rootViewController: StocksViewController(tableMode: true))
            window.makeKeyAndVisible()
            self.window = window
        }

        let noICView = NoInternetConnectionHeaderView()
        window?.addSubview(noICView)
        constrain(noICView) { noICView in
            noICView.left == noICView.superview!.left
            noICView.right == noICView.superview!.right
            noICView.top == noICView.superview!.top - 50
            noICView.height == 50
        }

        if !NetworkMonitor.sharedInstance.isConnected {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4) {
                    noICView.transform = CGAffineTransform(translationX: 0, y: 50)
                }
            }
        }

        NetworkMonitor.sharedInstance.didUpdateNetworkState = { state in
            if state {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        noICView.transform = CGAffineTransform.identity
                    }
                }
            } else {
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.4) {
                        noICView.transform = CGAffineTransform(translationX: 0, y: 50)
                    }
                }
            }
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
