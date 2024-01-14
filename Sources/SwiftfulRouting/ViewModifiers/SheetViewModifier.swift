//
//  SheetViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct SheetViewModifier: ViewModifier {
    
    let option: SegueOption
    let screens: Binding<[AnyDestination]>
    let sheetDetents: Set<PresentationDetentTransformable>
    @Binding var sheetSelection: PresentationDetentTransformable
    let sheetSelectionEnabled: Bool
    let showDragIndicator: Bool
    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(if: option, is: .sheet, value: Binding(toLastElementIn: screens)), onDismiss: onDismiss) { destination in
                if let view = screens.wrappedValue.last?.destination {
                    view
                        .presentationDetentsIfNeeded(
                            sheetDetents: sheetDetents,
                            sheetSelection: $sheetSelection,
                            sheetSelectionEnabled: sheetSelectionEnabled,
                            showDragIndicator: showDragIndicator)
                }
            }
    }
}

extension View {
    
    @ViewBuilder func presentationDetentsIfNeeded(
        sheetDetents: Set<PresentationDetentTransformable>,
        sheetSelection: Binding<PresentationDetentTransformable>,
        sheetSelectionEnabled: Bool,
        showDragIndicator: Bool) -> some View {
            if #available(iOS 16, *) {
                if sheetSelectionEnabled {
                    self
                        .presentationDetents(sheetDetents.setMap({ $0.asPresentationDetent }), selection: Binding(selection: sheetSelection))
                        .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                } else {
                    self
                        .presentationDetents(sheetDetents.setMap({ $0.asPresentationDetent }))
                        .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                }
            } else {
                self
            }
    }
}

