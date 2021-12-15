//
//  AppDelegate.swift
//  FreeCorner
//
//  Created by Simon Dahan on 07/12/2021.
//

import UIKit
import Firebase
import FirebaseDatabase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let ref = Database.database().reference()
        ref.removeValue()
        FireBaseService().populateOffer(name: "Chair", description: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries", images: ["https://media.4rgos.it/i/Argos/9393732_R_Z001A?w=750&h=440&qlt=70", "https://media.4rgos.it/i/Argos/9393732_R_Z001A?w=750&h=440&qlt=70"], owner: "1", category: "furniture") { _ in }
        FireBaseService().populateUser(name: "Dahan Simon", phone: "0659272810", address: ["Road Name": "84B avenue Pierre Mendes france","Postal Code": "94880", "City Name": "Noiseau"], offer: ["1","2"], email: "dahan.simon@hotmail.fr")
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

