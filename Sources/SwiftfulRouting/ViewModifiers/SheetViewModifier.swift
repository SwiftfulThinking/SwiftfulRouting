//
//  SheetViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct SheetViewModifier: ViewModifier {
    
    let option: SegueOption
    let items: Binding<[AnyDestination]>

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(if2: option, is: .sheet, value: items.wrappedValue.first), onDismiss: nil) { destination in
                if let view = items.first?.wrappedValue.destination {
                    view
                }
            }
    }
    
}
