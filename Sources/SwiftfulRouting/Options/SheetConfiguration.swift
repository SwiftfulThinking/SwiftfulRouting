//
//  SheetConfiguration.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

//@available(iOS 16.0, *)
//struct SheetConfiguration {
//    let detents: Set<PresentationDetent>
//    let selection: Binding<PresentationDetent>
//    let showDragIndicator: Visibility
//    
//    init(_ config: SheetConfig) {
//        self.detents = config.detents.setMap({ $0.asPresentationDetent })
//        self.showDragIndicator = config.showDragIndicator ? .visible : .hidden
//
//        self.selection = Binding(get: {
//            config.selection.wrappedValue.asPresentationDetent
//        }, set: { newValue, _ in
//            config.selection.wrappedValue = PresentationDetentTransformable(detent: newValue)
//        })
//    }
//}

/// Allows PresentationDetents to be injected without requiring iOS 16
//public struct SheetConfig {
//    let detents: Set<PresentationDetentTransformable>
//    let selection: Binding<PresentationDetentTransformable>
//    let showDragIndicator: Bool
//
//    public init(detents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool) {
//        self.detents = detents
//        self.selection = selection ?? .constant(.large)
//        self.showDragIndicator = showDragIndicator
//    }
//}

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
    
    public var title: String {
        switch self {
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        case .height(let height):
            return "Height: \(height) px"
        case .fraction(let fraction):
            return "Fraction: \((fraction * 100))%"
        case .unknown:
            return "unknown"
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}


