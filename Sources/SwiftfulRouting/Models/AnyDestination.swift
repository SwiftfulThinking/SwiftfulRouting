//
//  AnyDestination.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct AnyDestination: Identifiable {
    let id = UUID().uuidString
    let destination: AnyView

    init<T:View>(_ destination: T) {
        self.destination = AnyView(destination)
    }
}
