//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/10/24.
//

import Foundation
import SwiftUI

public struct TransitionConfiguration {
    let id = UUID().uuidString
    let removingCurrent: AnyTransition
    let insertingNext: AnyTransition
    let animation: Animation
    
    public init(removingCurrent: AnyTransition, insertingNext: AnyTransition, animation: Animation = .linear) {
        self.removingCurrent = removingCurrent
        self.insertingNext = insertingNext
        self.animation = animation
    }
    
    static let `default` = TransitionConfiguration(
        removingCurrent: .move(edge: .leading),
        insertingNext: .move(edge: .trailing),
        animation: .linear
    )
}
