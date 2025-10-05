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
        print("Creating new StableAnyDestinationArray")
        self.destinations = destinations
    }
    
    func setNewValueIfNeeded(newValue: [AnyDestination]) {
        print("StableAnyDestinationArray 1 - setNewValueIfNeeded - \(newValue.count)")
        if destinations != newValue {
            print("StableAnyDestinationArray 2 - setNewValueIfNeeded - \(newValue.count)")
            destinations = newValue
        }
    }

    static func == (lhs: StableAnyDestinationArray, rhs: StableAnyDestinationArray) -> Bool {
        lhs === rhs
    }
}
