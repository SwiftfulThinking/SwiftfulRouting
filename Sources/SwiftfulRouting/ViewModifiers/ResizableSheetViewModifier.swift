//
//  ResizableSheetViewModifier.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

// MARK: - Wrapper View with @Binding for Reactivity

/// This view uses @Binding to maintain reactive connection to the selection binding.
/// Based on the working implementation from commit bf0a8b4628b0e24d60f090b382c15b96329ab92c
private struct ResizableSheetContentWrapper<Content: View>: View {
    let content: Content
    let config: ResizableSheetConfig
    @Binding var selection: PresentationDetentTransformable

    var body: some View {
        let _ = print("🟢 [ResizableSheetContentWrapper] body evaluated with selection: \(selection.title)")

        content
            .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }), selection: Binding(selection: $selection))
            .presentationDragIndicator(config.dragIndicator)
            .applyEnvironmentBackgroundIfAvailable(option: config.background)
            .ifLetCondition(config.cornerRadius, transform: { content, value in
                content.presentationCornerRadiusIfAvailable(value)
            })
            .presentationBackgroundInteractionIfAvailable(config.backgroundInteraction)
            .presentationContentInteractionIfAvailable(config.contentInteraction)
    }
}

extension View {

    @ViewBuilder func applyResizableSheetModifiersIfNeeded(segue: SegueOption) -> some View {
        let _ = print("🔷 [ResizableSheetViewModifier] applyResizableSheetModifiersIfNeeded called")
        let _ = print("🔷 [ResizableSheetViewModifier]   - segue: \(segue.stringValue)")

        switch segue {
        case .push:
            self
        case .sheetConfig(config: let config):
            if let selection = config.selection {
                let _ = print("🔷 [ResizableSheetViewModifier] Using ResizableSheetContentWrapper with @Binding")
                let _ = print("🔷 [ResizableSheetViewModifier]   - Initial selection value: \(selection.wrappedValue.title)")

                // Use wrapper view with @Binding for reactive connection (based on old working implementation)
                ResizableSheetContentWrapper(
                    content: self,
                    config: config,
                    selection: selection
                )
            } else {
                let _ = print("🔷 [ResizableSheetViewModifier] No selection binding - using standard modifiers")

                // No selection binding - apply modifiers directly
                self
                    .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }))
                    .presentationDragIndicator(config.dragIndicator)
                    .applyEnvironmentBackgroundIfAvailable(option: config.background)
                    .ifLetCondition(config.cornerRadius, transform: { content, value in
                        content.presentationCornerRadiusIfAvailable(value)
                    })
                    .presentationBackgroundInteractionIfAvailable(config.backgroundInteraction)
                    .presentationContentInteractionIfAvailable(config.contentInteraction)
            }
        case .fullScreenCoverConfig(config: let config):
            self
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
