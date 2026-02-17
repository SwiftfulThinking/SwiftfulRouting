//
//  File.swift
//  
//
//  Created by Nick Sarno on 5/12/24.
//

import Foundation
import SwiftUI

extension View {
    
    @ViewBuilder func ifSatisfiesCondition<Content: View>(_ condition: Bool, transform: @escaping (Self) -> Content) -> some View {
        let _ = print("🔵 [View+EXT] ifSatisfiesCondition evaluated - condition: \(condition)")
        if condition {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func ifLetCondition<T, Content: View>(_ value: T?, transform: @escaping (Self, T) -> Content) -> some View {
        let hasValue = value != nil
        let _ = print("🔵 [View+EXT] ifLetCondition evaluated - has value: \(hasValue)")
        if let value {
            transform(self, value)
        } else {
            self
        }
    }

}
