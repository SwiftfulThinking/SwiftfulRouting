//
//  TransitionOption.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public enum TransitionOption: String, CaseIterable {
    case trailing, leading, top, bottom, identity
    
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
        case .identity:
            return .none
        default:
            return .smooth
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
        case .trailing: return .leading
        case .leading: return .trailing
        case .top: return .bottom
        case .bottom: return .top
        case .identity: return .identity
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

