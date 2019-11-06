//
//  AppDelegate.swift
//  Public Eyes
//
//  Created by Fitsyu  on 05/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit
import MediaPlayer
import Firebase

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        print("done launching")
        
        let board = UIStoryboard(name: "Navigation", bundle: nil)
        let vc0 = board.instantiateInitialViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)

        window?.rootViewController = vc0 //ExperimentViewController()

        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        return true
    }
    
}
