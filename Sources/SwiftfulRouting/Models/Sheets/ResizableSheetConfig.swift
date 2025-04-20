//
//  ResizableSheetConfig.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public struct ResizableSheetConfig {
    var detents: Set<PresentationDetentTransformable>
    var selection: Binding<PresentationDetentTransformable>?
    var dragIndicator: Visibility
    var background: EnvironmentBackgroundOption
    var cornerRadius: CGFloat?
    var backgroundInteraction: PresentationBackgroundInteractionBackSupport
    var contentInteraction: PresentationContentInteractionBackSupport

    /// Resizable sheet settings.
    /// - Parameters:
    ///   - detents: Array of sizes sheet can be.
    ///   - selection: Programatically set the selection. If nil, user can still swipe between sizes.
    ///   - dragIndicator: Show notch on top of sheet.
    ///   - background: Background of sheet. (supported on iOS 16.4 only!)
    ///   - cornerRadius: Corner radius of sheet. (supported on iOS 16.4 only!)
    ///   - backgroundInteraction: Background interaction of sheet (supported on iOS 16.4 only!)
    ///   - contentInteraction: Content interaction of sheet (supported on iOS 16.4 only!)
    public init(
        detents: Set<PresentationDetentTransformable> = [.large],
        selection: Binding<PresentationDetentTransformable>? = nil,
        dragIndicator: Visibility = .automatic,
        background: EnvironmentBackgroundOption = .automatic,
        cornerRadius: CGFloat? = nil,
        backgroundInteraction: PresentationBackgroundInteractionBackSupport = .automatic,
        contentInteraction: PresentationContentInteractionBackSupport = .automatic
    ) {
        self.detents = detents
        self.selection = selection
        self.dragIndicator = dragIndicator
        self.background = background
        self.cornerRadius = cornerRadius
        self.backgroundInteraction = backgroundInteraction
        self.contentInteraction = contentInteraction
    }
}

public enum PresentationBackgroundInteractionBackSupport {
    case automatic, disabled, enabled
    case enabledUpThrough(PresentationDetent)
    
    @available(iOS 16.4, *)
    var backgroundInteraction: PresentationBackgroundInteraction {
        switch self {
        case .automatic:
            return .automatic
        case .disabled:
            return .disabled
        case .enabled:
            return .enabled
        case .enabledUpThrough(let upThrough):
            return .enabled(upThrough: upThrough)
        }
    }
}

public enum PresentationContentInteractionBackSupport {
    case automatic, resizes, scrolls
    
    @available(iOS 16.4, *)
    var contentInteraction: PresentationContentInteraction {
        switch self {
        case .automatic:
            return .automatic
        case .resizes:
            return .resizes
        case .scrolls:
            return .scrolls
        }
    }
}
