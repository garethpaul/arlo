//
//  ViewController.swift
//  Arlo
//
//  Created by Gareth on 7/8/16.
//  Copyright © 2016 gpj. All rights reserved.
//

import UIKit
import AVFoundation
import Darwin
import Wit
import SCSiriWaveformView

class ViewController: UIViewController, AVSpeechSynthesizerDelegate, WitDelegate {
    /**
     * Called when the Wit request is completed.
     * param outcomes a NSDictionary of outcomes returned by the Wit API. Outcomes are ordered by confidence, highest first. Each outcome contains (at least) the following keys:
     *       intent, entities[], confidence, _text. For more information please refer to our online documentation: https://wit.ai/docs/http/20141022#get-intent-via-text-link
     *
     * param messageId the message id returned by the api
     * param customData any data attached when starting the request. See [Wit sharedInstance toggleCaptureVoiceIntent:... (id)customData] and [[Wit sharedInstance] start:... (id)customData];
     * param error Nil if no error occurred during processing
     */



    
    var talker = AVSpeechSynthesizer()
    var displayLink: CADisplayLink?
    private let witAudioPowerChangedNotification = Notification.Name(rawValue: "WITAudioPowerChanged")
    private var currentAudioLevel: CGFloat = 0
    
    @IBOutlet weak var waveView: SiriWaveformView!
    let btnVoiceRecog = WITMicButton()
    var pathLayer: CAShapeLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Wit.sharedInstance().delegate = self
        

       let utter = AVSpeechUtterance(string:"Hello my name is Arlo, talk to me!")
        
        let v = AVSpeechSynthesisVoice(language: "en-AU")
        utter.voice = v
        self.talker.delegate = self
        self.talker.speak(utter)
        
        _ = UIScreen.main.bounds
        _ = self.view.frame
        
        
        configureDisplayLink()
        configureAudioPowerObserver()
        
        let screenHeight = UIScreen.main.bounds.height
        
        
        btnVoiceRecog.frame = CGRect(x: 50, y: 50, width: 50, height: 50)
        btnVoiceRecog.center = CGPoint(x: self.view.center.x, y: screenHeight-50)
        
        self.view.addSubview(btnVoiceRecog)
        
        //
        let logo = UIImageView(image: UIImage(named:"arloLogo"))
        logo.frame = CGRect(x:25, y:25, width:25, height: 25)
        logo.center = CGPoint(x: self.view.center.x, y: screenHeight-50)
        logo.contentMode = UIViewContentMode.scaleAspectFit
        self.view.addSubview(logo)
        
    }
    
    func updateMeters() {
        waveView.updateWithLevel(currentAudioLevel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureDisplayLink()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        invalidateDisplayLink()
        talker.stopSpeaking(at: .immediate)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        invalidateDisplayLink()
    }

    private func configureDisplayLink() {
        if displayLink != nil {
            return
        }

        let link = CADisplayLink(target: self, selector: #selector(ViewController.updateMeters))
        link.add(to: RunLoop.current, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        link.isPaused = true
        displayLink = link
    }

    private func invalidateDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    private func configureAudioPowerObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.audioPowerDidChange(_:)), name: witAudioPowerChangedNotification, object: nil)
    }

    @objc private func audioPowerDidChange(_ notification: Notification) {
        guard let power = notification.object as? NSNumber else {
            currentAudioLevel = 0
            return
        }

        currentAudioLevel = normalizedWaveLevel(fromPower: power.floatValue)
    }

    private func normalizedWaveLevel(fromPower power: Float) -> CGFloat {
        let normalizedPower = CGFloat((power + 42.0) / 42.0)
        let clampedPower = max(CGFloat(0), min(CGFloat(1), normalizedPower))
        return pow(clampedPower, CGFloat(1.5))
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    }
    
    public func witDidGraspIntent(_ outcomes: [Any]!, messageId: String!, customData: Any!, error e: Error!) {
    }
    
    func witDidGetAudio(_ chunk: Data!) {
    }
    
    func witDidStartRecording() {
        currentAudioLevel = 0
        displayLink?.isPaused = false
    }
    
    func witDidStopRecording() {
        displayLink?.isPaused = true
        currentAudioLevel = 0
        waveView.updateWithLevel(0)
    }
    
    func witActivityDetectorStarted() {
        //
    }
    

}
