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
//                        .presentationDetentsIfAvailable(config: config, sheetSize: sheetSize)
//                        .onChange(of: config.selection.wrappedValue) { newValue in
//                            print("NEW VALUE!: \(newValue)")
//                        }
//                        .onAppear {
//                            print("STARIG VALUE: \(config.selection.wrappedValue)")
//                        }
//                        .onChange(of: sheetSize.wrappedValue) { newValue in
//                            print("222 NEW VALUE!: \(newValue)")
//                        }
//                        .onAppear {
//                            print("2244 VALUE: \(sheetSize.wrappedValue)")
//                        }
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
//            let configuration = SheetConfiguration(config)
//            if let selection = configuration.selection {
                self
//                .presentationDetents(configuration.detents, selection: configuration.selection)
//                .presentationDetents(sheetDetents, selection: Binding(get: {
//                    config.selection.wrappedValue.asPresentationDetent //?? config.detents.first?.asPresentationDetent ?? .large
//                }, set: { newValue, _ in
//                    config.selection.wrappedValue = PresentationDetentTransformable(detent: newValue)
//                }))
                .presentationDetents(sheetDetents.setMap({ $0.asPresentationDetent }), selection: Binding(get: {
                    sheetSize.wrappedValue.asPresentationDetent //?? config.detents.first?.asPresentationDetent ?? .large
                }, set: { newValue, _ in
                    sheetSize.wrappedValue = PresentationDetentTransformable(detent: newValue)
                }))
                .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
                    .onChange(of: sheetSize.wrappedValue) { newValue in
                        print("change config select: \(newValue)")
                    }
                    .onChange(of: sheetSize.wrappedValue) { newValue in
                        print("change config: \(newValue)")
                    }
//            } else {
//                self
//                    .presentationDetents(configuration.detents)
//                    .presentationDragIndicator(configuration.showDragIndicator)
//            }
        } else {
            self
        }
    }
}

