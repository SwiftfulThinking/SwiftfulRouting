//
//  AnyDestination.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct AnyDestination: Identifiable, Hashable {
    let id = UUID().uuidString
    let destination: AnyView

    init<T:View>(_ destination: T) {
        self.destination = AnyView(destination)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: AnyDestination, rhs: AnyDestination) -> Bool {
        lhs.id == rhs.id
    }
}
