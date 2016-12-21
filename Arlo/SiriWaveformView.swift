//
//  SiriWaveformView.swift
//  SiriWaveformView
//
//  Created by Jonathan on 3/14/15.
//  Copyright (c) 2015 Underwood. All rights reserved.
//

import UIKit
import Darwin

let pi = M_PI

@IBDesignable
open class SiriWaveformView: UIView {
    fileprivate var _phase: CGFloat = 0.0
    fileprivate var _amplitude: CGFloat = 0.0
    
    @IBInspectable open var waveColor: UIColor = UIColor.white
    @IBInspectable open var numberOfWaves = 5
    @IBInspectable open var primaryWaveLineWidth: CGFloat = 3.0
    @IBInspectable open var secondaryWaveLineWidth: CGFloat = 1.0
    @IBInspectable open var idleAmplitude: CGFloat = 0.01
    @IBInspectable open var frequency: CGFloat = 1.5
    @IBInspectable open var density: CGFloat = 5
    @IBInspectable open var phaseShift: CGFloat = -0.15
    
    @IBInspectable open var amplitude: CGFloat {
        get {
            return _amplitude
        }
    }
    
    open func updateWithLevel(_ level: CGFloat) {
        _phase += phaseShift
        _amplitude = fmax(level, idleAmplitude)
        setNeedsDisplay()
    }
    
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.clear(bounds)
        backgroundColor?.cgColor
        backgroundColor?.set()
        context!.fill(rect)
        
        // Draw multiple sinus waves, with equal phases but altered
        // amplitudes, multiplied by a parable function.
        for waveNumber in 0...numberOfWaves {
            let context = UIGraphicsGetCurrentContext()
            
            context!.setLineWidth((waveNumber == 0 ? primaryWaveLineWidth : secondaryWaveLineWidth))
            
            let halfHeight = bounds.height / 2.0
            let width = bounds.width
            let mid = width / 2.0
            
            let maxAmplitude = halfHeight - 4.0 // 4 corresponds to twice the stroke width
            
            // Progress is a value between 1.0 and -0.5, determined by the current wave idx, which is used to alter the wave's amplitude.
            let progress: CGFloat = 1.0 - CGFloat(waveNumber) / CGFloat(numberOfWaves)
            let normedAmplitude = (1.5 * progress - 0.5) * amplitude
            
            let multiplier: CGFloat = 1.0
            waveColor.withAlphaComponent(multiplier * waveColor.cgColor.alpha).set()
            
            var x: CGFloat = 0.0
            while x < width + density {
                // Use a parable to scale the sinus wave, that has its peak in the middle of the view.
                let scaling = -pow(1 / mid * (x - mid), 2) + 1
                
                // Original Code:
                // CGFloat y = scaling * maxAmplitude * normedAmplitude * sinf(2 * M_PI *(x / width) * self.frequency + self.phase) + halfHeight;
                let tempCasting: CGFloat = 2.0 * CGFloat(pi) * CGFloat(x / width) * frequency + _phase
                let y = scaling * maxAmplitude * normedAmplitude * CGFloat(sinf(Float(tempCasting))) + halfHeight
                
                if x == 0 {
                    context!.move(to: CGPoint(x: x, y: y))
                } else {
                    context!.addLine(to: CGPoint(x: x, y: y))
                }
                
                x += density
            }
            
            context!.strokePath()
        }
    }
}
