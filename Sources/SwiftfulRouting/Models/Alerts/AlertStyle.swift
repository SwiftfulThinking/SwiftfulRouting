//
//  AlertStyle.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public enum AlertStyle: String, CaseIterable, Hashable {
    case alert, confirmationDialog
    
    public var codeString: String {
        ".\(rawValue)"
    }
}
