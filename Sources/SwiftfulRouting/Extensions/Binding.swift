//
//  File.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

extension Binding where Value == Bool {
    
    init<T:Any>(ifNotNil value: Binding<T?>) {
        self.init {
            value.wrappedValue != nil
        } set: { _ in
            value.wrappedValue = nil
        }
    }
}
