//
//  UIViewBlurEffect.swift
//  ControlConfig
//
//  Created by f1shy-dev on 05/03/2023
//
        
import Combine
import Foundation
import SwiftUI
import UIKit

final class CustomIntensityVisualEffectView: UIVisualEffectView {
    /// Create visual effect view with given effect and its intensity
    ///
    /// - Parameters:
    ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
    ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
    init(effect: UIVisualEffect, intensity: CGFloat) {
        theEffect = effect
        customIntensity = intensity
        super.init(effect: nil)
    }
    
    required init?(coder aDecoder: NSCoder) { nil }
    
    deinit {
        animator?.stopAnimation(true)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        effect = nil
        animator?.stopAnimation(true)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
            self.effect = theEffect
        }
        animator?.fractionComplete = customIntensity
    }
    
    private let theEffect: UIVisualEffect
    public var customIntensity: CGFloat
    private var animator: UIViewPropertyAnimator?
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect
    }
}

struct CIVisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect
    @Binding var intensity: Double
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> CustomIntensityVisualEffectView {
        CustomIntensityVisualEffectView(effect: effect, intensity: CGFloat(intensity/100))
    }
    
    func updateUIView(_ uiView: CustomIntensityVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.customIntensity = CGFloat(intensity/100)
        uiView.effect = effect
        
        uiView.draw(uiView.bounds)
        uiView.setNeedsDisplay()
    }
}
