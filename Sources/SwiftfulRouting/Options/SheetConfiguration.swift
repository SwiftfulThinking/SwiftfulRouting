//
//  SheetConfiguration.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

@available(iOS 16.0, *)
struct SheetConfiguration {
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

/// Allows PresentationDetents to be injected without requiring iOS 16
public struct SheetConfig {
    let detents: Set<PresentationDetentTransformable>
    public let selection: Binding<PresentationDetentTransformable>?
    let showDragIndicator: Bool
    
    public init(detents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool) {
        self.detents = detents
        self.selection = selection
        self.showDragIndicator = showDragIndicator
    }
}

public enum PresentationDetentTransformable {
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


