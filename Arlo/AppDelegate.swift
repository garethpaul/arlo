//
//  AppDelegate.swift
//  Arlo
//
//  Created by Gareth on 7/8/16.
//  Copyright © 2016 gpj. All rights reserved.
//

import UIKit
import AVFoundation
import Wit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private static let witAccessToken = ""

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureAudioSession()
        configureWit()
        return true
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            NSLog("Unable to configure audio session: %@", String(describing: error))
        }
    }

    private func configureWit() {
        if !AppDelegate.witAccessToken.isEmpty {
            Wit.sharedInstance().accessToken = AppDelegate.witAccessToken
        }
        Wit.sharedInstance().detectSpeechStop = WITVadConfig.detectSpeechStop
    }

}
