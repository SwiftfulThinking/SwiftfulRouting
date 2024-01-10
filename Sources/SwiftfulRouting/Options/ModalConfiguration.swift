//
//  ModalConfiguration.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

public struct ModalConfiguration {
    let transition: AnyTransition
    let animation: Animation
    let alignment: Alignment
    let backgroundColor: Color?
    let backgroundEffect: BackgroundEffect?
    let useDeviceBounds: Bool
    
    static let `default` = ModalConfiguration(
        transition: .move(edge: .bottom),
        animation: .easeInOut,
        alignment: .bottom,
        backgroundColor: nil,
        backgroundEffect: nil,
        useDeviceBounds: true)
}

public struct BackgroundEffect {
    let effect: UIVisualEffect
    let opacity: CGFloat
    
    public init(effect: UIVisualEffect, opacity: CGFloat) {
        self.effect = effect
        self.opacity = opacity
    }
}

public struct AnimatedTransition {
    public let transition: AnyTransition
    public let animation: Animation
}

public struct TransitionConfiguration {
    let removingCurrent: AnimatedTransition
    let insertingNext: AnimatedTransition
    
    static let `default` = TransitionConfiguration(
        removingCurrent: AnimatedTransition(transition: .move(edge: .leading), animation: .linear),
        insertingNext: AnimatedTransition(transition: .move(edge: .trailing), animation: .linear)
    )
}
