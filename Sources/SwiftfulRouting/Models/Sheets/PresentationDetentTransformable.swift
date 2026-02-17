//
//  PresentationDetentTransformable.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public enum PresentationDetentTransformable: Hashable {
    case medium
    case large
    case height(CGFloat)
    case fraction(CGFloat)
    case unknown
    
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
        print("🟡 [PresentationDetentTransformable] Init from PresentationDetent -> \(self.title)")
    }

    var asPresentationDetent: PresentationDetent {
        let detent: PresentationDetent
        switch self {
        case .medium:
            detent = .medium
        case .large:
            detent = .large
        case .height(let height):
            detent = .height(height)
        case .fraction(let fraction):
            detent = .fraction(fraction)
        case .unknown:
            detent = .large
        }
        print("🟡 [PresentationDetentTransformable] Converting \(self.title) to PresentationDetent")
        return detent
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
