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
    let selection: Binding<PresentationDetentTransformable>?
    let showDragIndicator: Bool
    
    public init(detents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool) {
        self.detents = detents
        self.selection = selection
        self.showDragIndicator = showDragIndicator
        print("SHEET CONFIG STRUCT CREATED: \(selection?.wrappedValue)")
    }
    
//    public mutating func select(_ detent: PresentationDetentTransformable?) {
//        guard let detent else {
//            selection = nil
//            return
//        }
//        selection?.wrappedValue = detent
//    }
}

public enum PresentationDetentTransformable: Hashable {
    case medium
    case large
    case height(CGFloat)
    case fraction(CGFloat)
    case unknown
    
    @available(iOS 16.0, *)
    init(detent: PresentationDetent) {
        // FIXME: Unable to convert .height(CGFloat) and .fraction(CGFloat) back from PresentationDetent to PresentationDetentTransformable
        switch detent {
        case .medium:
            self = .medium
        case .large:
            self = .large
        default:
            self = .unknown
        }
    }
    
    @available(iOS 16.0, *)
    var asPresentationDetent: PresentationDetent {
        switch self {
        case .medium:
            return .medium
        case .large:
            return .large
        case .height(let height):
            return .height(height)
        case .fraction(let fraction):
            return .fraction(fraction)
        case .unknown:
            return .large
        }
    }
    
    private var id: String {
        switch self {
        case .medium:
            return "medium"
        case .large:
            return "large"
        case .height(let height):
            return "height_\(height)"
        case .fraction(let fraction):
            return "fraction_\(fraction)"
        case .unknown:
            return "unknown"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


