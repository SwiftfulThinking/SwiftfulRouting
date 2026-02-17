//
//  ResizableSheetViewModifier.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

extension View {
        
    @ViewBuilder func applyResizableSheetModifiersIfNeeded(segue: SegueOption) -> some View {
        let _ = print("🔷 [ResizableSheetViewModifier] applyResizableSheetModifiersIfNeeded called with segue: \(segue.stringValue)")

        switch segue {
        case .push:
            self
        case .sheetConfig(config: let config):
            let _ = print("🔷 [ResizableSheetViewModifier] Sheet config - detents: \(config.detents), selection: \(config.selection?.wrappedValue.title ?? "nil")")

            self
                // If a selection is passed in, bind to it
                .ifLetCondition(config.selection) { content, value in
                    let _ = print("🔷 [ResizableSheetViewModifier] Selection binding found, current value: \(value.wrappedValue.title)")
                    return content
                        .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }), selection: Binding(selection: value))
                }
                // Otherwise, don't pass in anything for the selection
                .ifSatisfiesCondition(config.selection == nil) { content in
                    let _ = print("🔷 [ResizableSheetViewModifier] No selection binding")
                    return content
                        .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }))
                }
            
                // Value for showing drag indicator
                .presentationDragIndicator(config.dragIndicator)
            
                // Add background color if needed
                .applyEnvironmentBackgroundIfAvailable(option: config.background)
            
                // Value for background corner radius
                .ifLetCondition(config.cornerRadius, transform: { content, value in
                    content
                        .presentationCornerRadiusIfAvailable(value)
                })
            
                // Background interaction
                .presentationBackgroundInteractionIfAvailable(config.backgroundInteraction)
            
                // Content interaction
                .presentationContentInteractionIfAvailable(config.contentInteraction)
        case .fullScreenCoverConfig(config: let config):
            self
                // Add background color if needed
                .applyEnvironmentBackgroundIfAvailable(option: config.background)
        }
    }
        
}

extension View {

    @ViewBuilder
    func presentationCornerRadiusIfAvailable(_ value: CGFloat) -> some View {
        if #available(iOS 16.4, *) {
            self.presentationCornerRadius(value)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func presentationBackgroundInteractionIfAvailable(_ interaction: PresentationBackgroundInteractionBackSupport) -> some View {
        if #available(iOS 16.4, *) {
            self.presentationBackgroundInteraction(interaction.backgroundInteraction)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func presentationContentInteractionIfAvailable(_ interaction: PresentationContentInteractionBackSupport) -> some View {
        if #available(iOS 16.4, *) {
            self.presentationContentInteraction(interaction.contentInteraction)
        } else {
            self
        }
    }
}
