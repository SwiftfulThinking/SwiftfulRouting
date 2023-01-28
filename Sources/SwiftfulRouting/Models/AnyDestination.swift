//
//  AnyDestination.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

public struct AnyDestination: Identifiable, Hashable {
    public let id = UUID().uuidString
    public let destination: AnyView

    public init<T:View>(_ destination: T) {
        self.destination = AnyView(destination)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.id == rhs.id
    }
    
    
}
