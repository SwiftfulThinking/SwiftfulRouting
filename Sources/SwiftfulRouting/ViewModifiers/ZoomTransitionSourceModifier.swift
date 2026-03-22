//
//  ZoomTransitionSourceModifier.swift
//  SwiftfulRouting
//
//  Created by Andrew Coyle on 26/01/2026.
//

import SwiftUI

// View modifier to mark a view as a transition source
public struct ZoomTransitionSourceModifier: ViewModifier {
    let transitionID: String
    let namespace: Namespace.ID

    @ViewBuilder
    public func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content
                .matchedTransitionSource(id: transitionID, in: namespace)
        } else {
            content
        }
    }
}

extension View {
    /// Marks this view as a source for a zoom transition.
    /// The transition ID must match the ID passed to the router when presenting a sheet or fullscreen cover.
    /// - Parameters:
    ///   - id: A unique identifier for this transition source
    ///   - namespace: The namespace to use for the transition
    /// - Returns: A view modified to act as a transition source
    public func zoomTransitionSource(id: String, namespace: Namespace.ID) -> some View {
        modifier(ZoomTransitionSourceModifier(transitionID: id, namespace: namespace))
    }
}
