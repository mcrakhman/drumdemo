//
//  AppDelegate.swift
//  DrumMachineDemo
//
//  Created by m.rakhmanov on 25.11.16.
//  Copyright © 2016 m.rakhmanov. All rights reserved.
//

import UIKit
import Parse

enum ParseConstants {
    static let appId = "1yEfEZBGIfr2bjxVns5xtTKNLlXCwUdd7pAPnQXs"
    static let clientKey = "roCxcVNd0w7pIVlvkDQtNoryaus8ivMMPOXUiPtA"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Parse.enableLocalDatastore()
        Parse.setApplicationId(ParseConstants.appId,
                               clientKey: ParseConstants.clientKey)
        
        return true
    }
}

