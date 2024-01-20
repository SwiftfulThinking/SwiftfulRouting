//
//  ModalConfiguration.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

public struct ModalConfiguration {
    let transition: TransitionOption
    let animation: Animation
    let alignment: Alignment
    let backgroundColor: Color?
    let ignoreSafeArea: Bool
    
    static let `default` = ModalConfiguration(
        transition: .bottom,
        animation: .easeInOut,
        alignment: .bottom,
        backgroundColor: nil,
        ignoreSafeArea: true
    )
}

public struct BackgroundEffect {
    let effect: UIVisualEffect
    let opacity: CGFloat
    
    public init(effect: UIVisualEffect, opacity: CGFloat) {
        self.effect = effect
        self.opacity = opacity
    }
}
