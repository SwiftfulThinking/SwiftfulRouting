//
//  TransitionOption.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public enum TransitionOption: CaseIterable, Equatable {
    public static var allCases: [TransitionOption] {
        [.trailing(), .leading(), .top(), .bottom(), .identity]
    }
    
    case trailing(animation: Animation = .snappy)
    case leading(animation: Animation = .snappy)
    case top(animation: Animation = .snappy)
    case bottom(animation: Animation = .snappy)
    case identity
    
    var id: String {
        switch self {
        case .trailing:
            return "trailing"
        case .leading:
            return "leading"
        case .top:
            return "top"
        case .bottom:
            return "bottom"
        case .identity:
            return "identity"
        }
    }
    
    var canSwipeBack: Bool {
        switch self {
        case .trailing, .leading:
            return true
        default:
            return false
        }
    }
    
    var animation: Animation? {
        switch self {
        case .trailing(let animation), .leading(let animation), .top(let animation), .bottom(let animation):
            return animation
        case .identity:
            return .none
        }
    }
    
    var insertion: AnyTransition {
        switch self {
        case .trailing:
            return .move(edge: .trailing)
        case .leading:
            return .move(edge: .leading)
        case .top:
            return .move(edge: .top)
        case .bottom:
            return .move(edge: .bottom)
        case .identity:
            // Note: This will NOT work with .identity (idk why)
            // SwiftUI renders .identity differently than .move transitions
            // Instead, we keep this as .move(.leading) and will set animation = .none
            // to get the same result!
            return .move(edge: .leading)
        }
    }
    
    var reversed: TransitionOption {
        switch self {
        case .trailing(let animation):
            return .leading(animation: animation)
        case .leading(let animation):
            return .trailing(animation: animation)
        case .top(let animation):
            return .bottom(animation: animation)
        case .bottom(let animation):
            return .top(animation: animation)
        case .identity:
            return .identity
        }
    }
    
    var asAlignment: Alignment {
        switch self {
        case .trailing:
            return .trailing
        case .leading:
            return .leading
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .identity:
            return .center
        }
    }
    
    var asAxis: Axis.Set {
        switch self {
        case .trailing:
            return .horizontal
        case .leading:
            return .horizontal
        case .top:
            return .vertical
        case .bottom:
            return .vertical
        case .identity:
            return .horizontal
        }
    }

}

