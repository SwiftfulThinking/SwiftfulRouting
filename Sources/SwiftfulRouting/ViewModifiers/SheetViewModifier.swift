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
    let items: Binding<[AnyDestination]>
    let sheetDetents: Set<PresentationDetentTransformable>
    @Binding var sheetSize: PresentationDetentTransformable
    let showDragIndicator: Bool

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(if: option, is: .sheet, value: bindingToLastElement(in: items)), onDismiss: nil) { destination in
                if let view = items.wrappedValue.last?.destination {
                    view
                        .presentationDetentsIfAvailable(sheetDetents: sheetDetents, sheetSize: $sheetSize, showDragIndicator: showDragIndicator)
                }
            }
    }
}

extension View {
    
    @ViewBuilder func presentationDetentsIfAvailable(
        sheetDetents: Set<PresentationDetentTransformable>,
        sheetSize: Binding<PresentationDetentTransformable>,
        showDragIndicator: Bool) -> some View {
            if #available(iOS 16, *) {
                self
                    .presentationDetents(sheetDetents.setMap({ $0.asPresentationDetent }), selection: Binding(get: {
                        sheetSize.wrappedValue.asPresentationDetent //?? config.detents.first?.asPresentationDetent ?? .large
                    }, set: { newValue, _ in
                        sheetSize.wrappedValue = PresentationDetentTransformable(detent: newValue)
                    }))
                    .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
            } else {
                self
            }
    }
}

