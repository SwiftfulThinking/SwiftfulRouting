//
//  ResizableSheetViewModifier.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

extension View {
        
    @ViewBuilder func applyResizableSheetModifiersIfNeeded(segue: SegueOption) -> some View {
        switch segue {
        case .push:
            self
        case .sheetConfig(config: let config):
            self
                // If a selection is passed in, bind to it
                .ifLetCondition(config.selection) { content, value in
                    content
                        .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }), selection: Binding(selection: value))
                }
                // Otherwise, don't pass in anything for the selection
                .ifSatisfiesCondition(config.selection == nil) { content in
                    content
                        .presentationDetents(config.detents.setMap({ $0.asPresentationDetent }))
                }
            
                // Value for showing drag indicator
                .presentationDragIndicator(config.dragIndicator)
            
                // Add background color if needed
                .applyEnvironmentBackground(option: config.background)
            
                // Value for background corner radius
                .ifLetCondition(config.cornerRadius, transform: { content, value in
                    content
                        .presentationCornerRadius(value)
                })
            
                // Background interaction
                .presentationBackgroundInteraction(config.backgroundInteraction)
            
                // Content interaction
                .presentationContentInteraction(config.contentInteraction)
        case .fullScreenCoverConfig(config: let config):
            self
                // Add background color if needed
                .applyEnvironmentBackground(option: config.background)
        }
    }
        
}
