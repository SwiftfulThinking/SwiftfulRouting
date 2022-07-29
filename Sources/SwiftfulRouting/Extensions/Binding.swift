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

extension Binding where Value == AnyDestination? {
    
    init(if selected: SegueOption, is option: SegueOption, value: Binding<AnyDestination?>) {
        self.init {
            selected == option ? value.wrappedValue : nil
        } set: { newValue in
            value.wrappedValue = newValue
        }
    }
}
