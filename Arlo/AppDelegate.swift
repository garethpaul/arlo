//
//  AppDelegate.swift
//  Arlo
//
//  Created by Gareth on 7/8/16.
//  Copyright © 2016 gpj. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import Wit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        

        try! AVAudioSession.sharedInstance().setActive(true)
        
        Wit.sharedInstance().accessToken = ""
        Wit.sharedInstance().detectSpeechStop = WITVadConfig.detectSpeechStop
        
        return true
    }

}

