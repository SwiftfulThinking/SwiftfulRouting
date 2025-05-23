//
//  StablePath.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 5/22/25.
//
import SwiftUI

final class StableAnyDestinationArray: ObservableObject, Equatable {
    @Published var destinations: [AnyDestination]

    init(destinations: [AnyDestination]) {
        self.destinations = destinations
    }
    
    func setNewValueIfNeeded(newValue: [AnyDestination]) {
        if destinations != newValue {
            destinations = newValue
        }
    }

    static func == (lhs: StableAnyDestinationArray, rhs: StableAnyDestinationArray) -> Bool {
        lhs === rhs
    }
}
