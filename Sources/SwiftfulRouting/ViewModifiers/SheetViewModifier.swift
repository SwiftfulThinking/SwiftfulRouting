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

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(if: option, is: .sheet, value: bindingToLastElement(in: items)), onDismiss: nil) { destination in
                if let view = items.wrappedValue.last?.destination {
                    view
                }
            }
    }
    
}

@available(iOS 16, *)
struct ResizableSheetViewModifier: ViewModifier {
    
    let option: SegueOption
    let items: Binding<[AnyDestination]>
    let config: SheetConfig?

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(if: option, is: .sheet, value: bindingToLastElement(in: items)), onDismiss: nil) { destination in
                if let view = items.wrappedValue.last?.destination {
                    view
                        .presentationDetentsConfig(config: config)
                }
            }
    }
}

extension View {
    
    @available(iOS 16.0, *)
    @ViewBuilder func presentationDetentsConfig(config: SheetConfig?) -> some View {
        if let config {
            let configuration = SheetPresentationConfiguration(config)
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



/// Allows PresentationDetents to be injected without requiring iOS 16
struct SheetConfig {
    let detents: Set<PresentationDetentTransformable>
    let selection: Binding<PresentationDetentTransformable>?
    let showDragIndicator: Bool
}

enum PresentationDetentTransformable {
    case medium
    case large
    
    @available(iOS 16.0, *)
    init(detent: PresentationDetent) {
        switch detent {
        case .medium:
            self = .medium
        case .large:
            self = .large
        default:
            self = .large
        }
    }
    
    @available(iOS 16.0, *)
    var asPresentationDetent: PresentationDetent {
        switch self {
        case .medium:
            return .medium
        case .large:
            return .large
        }
    }
}


@available(iOS 16.0, *)
struct SheetPresentationConfiguration {
    let detents: Set<PresentationDetent>
    let selection: Binding<PresentationDetent>?
    let showDragIndicator: Visibility
    
    init(_ config: SheetConfig) {
        self.detents = config.detents.setMap({ $0.asPresentationDetent })
        if let selection = config.selection {
            self.selection = Binding(get: {
                selection.wrappedValue.asPresentationDetent
            }, set: { newValue, _ in
                selection.wrappedValue = PresentationDetentTransformable(detent: newValue)
            })
        } else {
            self.selection = nil
        }
        self.showDragIndicator = config.showDragIndicator ? .visible : .hidden
    }
}

extension Set {
    func setMap<U>(_ transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}
