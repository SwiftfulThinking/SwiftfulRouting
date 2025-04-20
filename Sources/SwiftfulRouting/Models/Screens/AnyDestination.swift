//
//  AnyDestination.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//
import Foundation
import SwiftUI

@MainActor
public struct AnyDestination: Identifiable, Hashable {
    public private(set) var id: String
    public let segue: SegueOption
    public let location: SegueLocation
    public let animates: Bool
    public let destination: AnyView
    public let onDismiss: (() -> Void)?
    public let transitionBehavior: TransitionMemoryBehavior
    
    /// - Parameters:
    ///   - id: Identifier for the screen
    ///   - segue: Push (NavigationLink), Sheet, or FullScreenCover
    ///   - location: Where to insert the new screen in the heirarchy (default = .insert)
    ///   - animates: If the segue should animate or not (default = true)
    ///   - transitionBehavior: Determines the behavior of "transition" methods on the destination screen.
    ///   - onDismiss: Trigger closure when screen gets dismissed (note: dismiss != disappear)
    ///   - destination: The destination screen.
    public init<T:View>(
        id: String = UUID().uuidString,
        segue: SegueOption = .push,
        location: SegueLocation = .insert,
        animates: Bool = true,
        transitionBehavior: TransitionMemoryBehavior = .keepPrevious,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) {
        self.id = id
        self.segue = segue
        self.location = location
        self.animates = animates
        self.transitionBehavior = transitionBehavior
        self.destination = AnyView(
            RouterViewInternal(
                routerId: id,
                rootRouterInfo: nil,
                addNavigationStack: segue != .push,
                content: destination
            )
        )
        self.onDismiss = onDismiss
    }
    
    nonisolated public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    nonisolated public static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func updateScreenId(newValue: String) {
        id = newValue
    }
    
    public var eventParameters: [String: Any] {
        [
            "destination_id": id,
            "destination_segue": segue.stringValue,
            "destination_location": location.stringValue,
            "destination_animates": animates,
            "destination_has_on_dismiss": onDismiss != nil,
            "destination_transition_behavior": transitionBehavior.rawValue,
        ]
    }
}
