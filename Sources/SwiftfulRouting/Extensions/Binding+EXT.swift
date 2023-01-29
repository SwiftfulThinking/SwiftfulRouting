//
//  File+EXT.swift
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

func bindingToLastElement<T>(in array: Binding<[T]>) -> Binding<T?> {
    Binding {
        array.wrappedValue.last
    } set: { newValue, _ in
        if array.wrappedValue.last != nil {
            array.wrappedValue.removeLast()
        }
    }
}

/*

 */
