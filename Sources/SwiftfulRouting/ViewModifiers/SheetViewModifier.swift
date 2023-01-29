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
    let config: SheetConfig?

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(if: option, is: .sheet, value: bindingToLastElement(in: items)), onDismiss: nil) { destination in
                if let view = items.wrappedValue.last?.destination {
                    view
                        .presentationDetentsIfAvailable(config: config)
                        .onChange(of: config?.selection?.wrappedValue) { newValue in
                            print("NEW VALUE!: \(newValue)")
                        }
                }
            }
    }
}

extension View {
    
    @ViewBuilder func presentationDetentsIfAvailable(config: SheetConfig?) -> some View {
        if #available(iOS 16, *), let config {
            let configuration = SheetConfiguration(config)
            if let selection = configuration.selection {
                self
                    .presentationDetents(configuration.detents, selection: selection)
                    .presentationDragIndicator(configuration.showDragIndicator)
            } else {
                self
                    .presentationDetents(configuration.detents)
                    .presentationDragIndicator(configuration.showDragIndicator)
            }
        } else {
            self
        }
    }
}

