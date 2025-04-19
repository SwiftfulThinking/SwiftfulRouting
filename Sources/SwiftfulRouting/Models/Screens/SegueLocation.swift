//
//  SegueLocation.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public enum SegueLocation {
    /// Insert screen at the location of the call-site's router
    case insert
    /// Append screen to the end of the active stack
    case append
    /// Insert screen after the location injected screen's router
    case insertAfter(id: String)
    
    var stringValue: String {
        switch self {
        case .insert:
            return "insert"
        case .append:
            return "append"
        case .insertAfter:
            return "insert_after"
        }
    }
}
