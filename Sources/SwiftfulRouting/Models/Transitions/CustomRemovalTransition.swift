//
//  CustomRemovalTransition.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

struct CustomRemovalTransition: ViewModifier {
    var behavior: TransitionMemoryBehavior
    let option: TransitionOption?
    var frame: CGRect

    func body(content: Content) -> some View {
        content
            .offset(x: xOffset, y: yOffset)
    }
    
    private var xOffset: CGFloat {
        switch option {
        case .trailing:
            return frame.width
        case .leading:
            return -frame.width
        default:
            return 0
        }
    }
    
    private var yOffset: CGFloat {
        switch option {
        case .top:
            return -frame.height
        case .bottom:
            return frame.height
        default:
            return 0
        }
    }
}

extension AnyTransition {
    
    @MainActor
    static func customRemoval(
        behavior: TransitionMemoryBehavior,
        direction: TransitionOption,
        frame: CGRect
    ) -> AnyTransition {
        .modifier(
            active: CustomRemovalTransition(behavior: behavior, option: direction, frame: frame),
            identity: CustomRemovalTransition(behavior: behavior, option: nil, frame: frame)
        )
    }
    
}
