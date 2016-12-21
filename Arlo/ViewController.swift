//
//  ViewController.swift
//  Arlo
//
//  Created by Gareth on 7/8/16.
//  Copyright © 2016 gpj. All rights reserved.
//

import UIKit
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
    var displayLink = CADisplayLink()
    
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
        
        
        displayLink = CADisplayLink(target: self, selector: #selector(ViewController.updateMeters))
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode(rawValue: RunLoopMode.commonModes.rawValue))
        
        displayLink.isPaused = true
        
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
        
        let talk = btnVoiceRecog.volumeLayer.contentsScale
        
        print(talk)
        
        //CircleView.lineWidth
        
        if talk == 2 {
            let normalizedValue:CGFloat = pow(10, CGFloat(1)/20)
            waveView.updateWithLevel(normalizedValue)
        } else {
            waveView.updateWithLevel(0)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        print("starting")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("finished")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let s = (utterance.speechString as NSString).substring(with: characterRange)
        print("about to say \(s)")
    }
    
    public func witDidGraspIntent(_ outcomes: [Any]!, messageId: String!, customData: Any!, error e: Error!) {
        
        if (e != nil) {
            
        }
        else {
            if outcomes != nil && outcomes.count > 0 {
                print(outcomes)
                
            }
            
        }
    }
    
    func witDidGetAudio(_ chunk: Data!) {
        print("did get audio")
    }
    
    func witDidStartRecording() {
        displayLink.isPaused = false
    }
    
    func witDidStopRecording() {
        displayLink.isPaused = true
        waveView.updateWithLevel(0)
    }
    
    func witActivityDetectorStarted() {
        //
    }
    

}

