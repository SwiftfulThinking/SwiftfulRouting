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
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func ifLetCondition<T, Content: View>(_ value: T?, transform: @escaping (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }

}
