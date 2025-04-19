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
    var backgroundInteraction: PresentationBackgroundInteraction
    var contentInteraction: PresentationContentInteraction

    public init(
        detents: Set<PresentationDetentTransformable> = [.large],
        selection: Binding<PresentationDetentTransformable>? = nil,
        dragIndicator: Visibility = .automatic,
        background: EnvironmentBackgroundOption = .automatic,
        cornerRadius: CGFloat? = nil,
        backgroundInteraction: PresentationBackgroundInteraction = .automatic,
        contentInteraction: PresentationContentInteraction = .automatic
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
