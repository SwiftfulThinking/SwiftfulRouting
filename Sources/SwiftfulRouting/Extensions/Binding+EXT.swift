//
//  Binding+EXT.swift
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

extension Binding where Value == AnyAlert? {
    
    init(if selected: DialogOption, is option: DialogOption, value: Binding<AnyAlert?>) {
        self.init {
            selected == option ? value.wrappedValue : nil
        } set: { newValue in
            value.wrappedValue = newValue
        }
    }
}

extension Binding where Value == Array<AnyDestination> {
    
    init(if selected: SegueOption, is option: SegueOption, value: Binding<[AnyDestination]>) {
        self.init {
            selected == option ? value.wrappedValue : []
        } set: { newValue in
            value.wrappedValue = newValue
        }
    }
    
}

@available(iOS 16, *)
extension Binding where Value == PresentationDetent {
    
    init(selection: Binding<PresentationDetentTransformable>) {
        self.init {
            selection.wrappedValue.asPresentationDetent
        } set: { newValue in
            selection.wrappedValue = PresentationDetentTransformable(detent: newValue)
        }
    }
    
}


extension Binding {
    
    init<V:Hashable>(toLastElementIn array: Binding<[V]>) where Value == V? {
        self.init {
            array.wrappedValue.last
        } set: { newValue in
            if let newValue {
                // Check for newValue in array before updating
                if let index = array.wrappedValue.firstIndex(of: newValue) {
                    array.wrappedValue[index] = newValue
                }
            } else {
                // Check for last item in array before removing (not safe)
                if array.wrappedValue.last != nil {
                    array.wrappedValue.removeLast()
                }
            }
        }
    }
}
