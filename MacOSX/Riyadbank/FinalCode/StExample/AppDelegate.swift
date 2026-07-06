//
//  AppDelegate.swift
//  StExample
//
//  Created by Suman Naskar on 04/12/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    
   
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        for family in UIFont.familyNames {
//            print("Family: \(family)")
//            for name in UIFont.fontNames(forFamilyName: family) {
//                print("   Font: \(name)")
//            }
//        }
       
        if let labelFont = UIFont(name: "RBType-RB-Regular", size: 17) {
            UILabel.appearance().font = labelFont
        } else {
            print("RBType-RB-Regular font not found!")
        }

        if let buttonFont = UIFont(name: "RBType-RB-Medium", size: 17) {
            UIButton.appearance().titleLabel?.font = buttonFont
        } else {
            print("RBType-RB-Medium font not found!")
        }

        if let navBoldFont = UIFont(name: "RBType-RB-Bold", size: 20) {
            UINavigationBar.appearance().titleTextAttributes = [
                NSAttributedString.Key.font: navBoldFont
            ]
        }


        return true
    }

    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
