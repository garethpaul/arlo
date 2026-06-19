//
//  AppDelegate.swift
//  Arlo
//
//  Created by Gareth on 7/8/16.
//  Copyright © 2016 gpj. All rights reserved.
//

import UIKit
import Wit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private static let witAccessToken = ""
    static var isWitConfigured: Bool {
        guard !witAccessToken.isEmpty && witAccessToken.characters.count <= 4096 else {
            return false
        }
        return witAccessToken.rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil &&
            witAccessToken.rangeOfCharacter(from: CharacterSet.controlCharacters) == nil
    }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        configureWit()
        return true
    }

    private func configureWit() {
        guard AppDelegate.isWitConfigured else {
            return
        }

        let wit = Wit.sharedInstance()
        wit.accessToken = AppDelegate.witAccessToken
        wit.detectSpeechStop = WITVadConfig.detectSpeechStop
    }

}
