//
//  ZoomTransitionWrapper.swift
//  SwiftfulRouting
//
//  Created by Andrew Coyle on 26/01/2026.
//

import SwiftUI

/// A wrapper view that applies zoom transition to its content.
/// This should wrap destination views when presenting sheets or fullscreen covers with zoom transitions.
public struct ZoomTransitionWrapper<Content: View>: View {
    let transitionID: String
    let namespace: Namespace.ID
    @ViewBuilder let content: () -> Content
    
    public init(transitionID: String, namespace: Namespace.ID, @ViewBuilder content: @escaping () -> Content) {
        self.transitionID = transitionID
        self.namespace = namespace
        self.content = content
    }
    
    @ViewBuilder
    public var body: some View {
        if #available(iOS 18.0, *) {
            content()
                .navigationTransition(.zoom(sourceID: transitionID, in: namespace))
        } else {
            content()
        }
    }
}
