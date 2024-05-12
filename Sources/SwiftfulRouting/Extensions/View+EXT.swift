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
    
}
