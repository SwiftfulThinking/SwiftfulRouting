//
//  Binding+EXT.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

//@MainActor
//extension Binding where Value == [AnyDestination] {
//    
//    init(stack: [AnyDestinationStack], routerId: String, onDidDismiss: @escaping (_ lastRouteRemaining: AnyDestination?) -> Void) {
//        self.init {
//            let index = stack.firstIndex { subStack in
//                return subStack.screens.contains(where: { $0.id == routerId })
//            }
//            guard let index, stack.indices.contains(index + 1) else {
//                return []
//            }
//            return stack[index + 1].screens
//        } set: { newValue in
//            // User manually swiped back on screen
//            
//            let index = stack.firstIndex { subStack in
//                return subStack.screens.contains(where: { $0.id == routerId })
//            }
//            guard let index, stack.indices.contains(index + 1) else {
//                return
//            }
//            
//            if newValue.count < stack[index + 1].screens.count {
//                onDidDismiss(newValue.last)
//            }
//        }
//    }
//}

@MainActor
extension Binding where Value == AnyDestination? {
    
    init(stack: [AnyDestinationStack], routerId: String, segue: SegueOption, isResizeableSheet: Bool, onDidDismiss: @escaping () -> Void) {
        self.init {
            let routerStackIndex = stack.firstIndex { subStack in
                return subStack.screens.contains(where: { $0.id == routerId })
            }
            
            guard let routerStackIndex else {
                return nil
            }
            
            let routerStack = stack[routerStackIndex]

            if routerStack.segue == .push, routerStack.screens.last?.id != routerId {
                return nil
            }
            
            var nextSheetStack: AnyDestinationStack?
            if routerStack.segue == .push, stack.indices.contains(routerStackIndex + 1) {
                nextSheetStack = stack[routerStackIndex + 1]
            } else if stack.indices.contains(routerStackIndex + 2) {
                nextSheetStack = stack[routerStackIndex + 2]
            }

            if let nextSegue = nextSheetStack?.segue, nextSegue == segue, let screen = nextSheetStack?.screens.first {
                if isResizeableSheet && nextSegue.isResizeableSheet {
                    return screen
                }
                if !isResizeableSheet && !nextSegue.isResizeableSheet {
                    return screen
                }
            }
            
            return nil
        } set: { newValue in
            // User manually swiped down on environment
            if newValue == nil {
                onDidDismiss()
            }
        }
    }
}

@MainActor
extension Binding where Value == Bool {
    
    init(ifAlert alert: Binding<AnyAlert?>, isStyle style: AlertStyle) {
        self.init(get: {
            if let alertStyle = alert.wrappedValue?.style, alertStyle == style {
                return true
            }
            return false
        }, set: { newValue in
            if newValue == false {
                alert.wrappedValue = nil
            }
        })
    }
}

@MainActor
extension Binding where Value == PresentationDetent {
    
    init(selection: Binding<PresentationDetentTransformable>) {
        self.init {
            selection.wrappedValue.asPresentationDetent
        } set: { newValue in
            selection.wrappedValue = PresentationDetentTransformable(detent: newValue)
        }
    }
    
}
