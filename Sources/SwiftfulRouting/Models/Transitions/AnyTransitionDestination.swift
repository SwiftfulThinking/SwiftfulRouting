//
//  AnyTransitionDestination.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI
import SwiftfulRecursiveUI

public struct AnyTransitionDestination: Identifiable, Equatable {
    public private(set) var id: String = UUID().uuidString
    public private(set) var transition: TransitionOption = .trailing
    public private(set) var allowsSwipeBack: Bool = true
    public private(set) var onDismiss: (() -> Void)? = nil
    public private(set) var destination: (AnyRouter) -> any View
    
    /// Transition current screen.
    /// - Parameters:
    ///   - transition: Transition animation option.
    ///   - id: Identifier for transition id.
    ///   - allowsSwipeBack: Add a swipe-back gesture to the edge of the screen. Note: only works with .trailing or .leading transitions.
    ///   - onDismiss: Closure that triggers when transition is dismissed.
    ///   - destination: Destination screen.
    public init(
        id: String,
        transition: TransitionOption = .trailing,
        allowsSwipeBack: Bool = false,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> any View
    ) {
        self.id = id
        self.transition = transition
        self.allowsSwipeBack = allowsSwipeBack
        self.onDismiss = onDismiss
        self.destination = destination
    }
    
    static var root: AnyTransitionDestination {
        AnyTransitionDestination(id: "root", transition: .trailing, destination: { _ in
            EmptyView()
        })
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyTransitionDestination, rhs: AnyTransitionDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    public var eventParameters: [String: Any] {
        [
            "destination_id": id,
            "destination_transition": transition.rawValue,
            "destination_allow_swipe_back": allowsSwipeBack,
            "destination_has_on_dismiss": onDismiss != nil,
        ]
    }
}
