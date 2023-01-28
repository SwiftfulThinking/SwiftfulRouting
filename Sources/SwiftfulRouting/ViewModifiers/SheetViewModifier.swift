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
    let item: Binding<AnyDestination?>

    func body(content: Content) -> some View {
        content
            .sheet(item: Binding(if: option, is: .sheet, value: item), onDismiss: nil) { destination in
                RouterView {
                    if let view = item.wrappedValue?.destination {
                        view
                    }
                }
            }
    }
}
