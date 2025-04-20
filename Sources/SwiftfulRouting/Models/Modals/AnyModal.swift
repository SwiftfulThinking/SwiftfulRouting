//
//  AnyModal.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public struct AnyModal: Identifiable, Equatable {
    public private(set) var id: String
    public private(set) var transition: AnyTransition
    public private(set) var animation: Animation
    public private(set) var alignment: Alignment
    public private(set) var backgroundColor: Color?
    public private(set) var backgroundEffect: BackgroundEffect?
    public private(set) var dismissOnBackgroundTap: Bool
    public private(set) var ignoreSafeArea: Bool
    public private(set) var destination: AnyView
    public private(set) var onDismiss: (() -> Void)?
    public private(set) var isRemoved: Bool = false
    
    /// Show a modal.
    /// - Parameters:
    ///   - id: Identifier for modal.
    ///   - transition: Transition to show and hide modal.
    ///   - animation: Animation to show and hide modal.
    ///   - alignment: Alignment within the screen.
    ///   - backgroundColor: Background color behind the modal, if applicable.
    ///   - backgroundEffect: Background effect behind the modal, if applicable.
    ///   - dismissOnBackgroundTap: If there is a background color/effect, add tap gesture that dismisses the modal.
    ///   - ignoreSafeArea: Ignore screen's safe area when displayed.
    ///   - onDismiss: Closure that triggers when modal dismisses.
    ///   - destination: The modal View.
    public init<T:View>(
        id: String = UUID().uuidString,
        transition: AnyTransition = .identity,
        animation: Animation = .smooth,
        alignment: Alignment = .center,
        backgroundColor: Color? = nil,
        backgroundEffect: BackgroundEffect? = nil,
        dismissOnBackgroundTap: Bool = true,
        ignoreSafeArea: Bool = true,
        destination: @escaping () -> T,
        onDismiss: (() -> Void)? = nil
    ) {
        self.id = id
        self.transition = transition
        self.animation = animation
        self.alignment = alignment
        self.backgroundColor = backgroundColor
        self.backgroundEffect = backgroundEffect
        self.dismissOnBackgroundTap = dismissOnBackgroundTap
        self.ignoreSafeArea = ignoreSafeArea
        self.destination = AnyView(
            destination()
        )
        self.onDismiss = onDismiss
    }
    
    var hasBackgroundLayer: Bool {
        backgroundColor != nil || backgroundEffect != nil
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyModal, rhs: AnyModal) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func convertToEmptyRemovedModal() {
        id = "removed_\(id)"
        backgroundColor = nil
        backgroundEffect = nil
        dismissOnBackgroundTap = false
        destination = AnyView(
            EmptyView().allowsHitTesting(false)
        )
        onDismiss = nil
        isRemoved = true
    }
    
    public var eventParameters: [String: Any] {
        [
            "modal_id": id,
            "modal_is_removed": isRemoved,
            "modal_dismiss_bg_tap": dismissOnBackgroundTap,
            "modal_has_background_color": backgroundColor != nil,
            "modal_has_background_effect": backgroundEffect != nil,
            "modal_has_on_dismiss": onDismiss != nil,
        ]
    }
}

public extension Array where Element == AnyModal {
    
    var active: Self {
        filter({ !$0.isRemoved })
    }
    
    var removed: Self {
        filter({ $0.isRemoved })
    }
}
