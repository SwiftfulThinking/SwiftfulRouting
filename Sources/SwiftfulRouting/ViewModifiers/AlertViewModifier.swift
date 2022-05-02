//
//  AlertViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

@available (iOS 15, *)
struct AlertViewModifier: ViewModifier {
    
    let item: Binding<AnyAlert?>

    func body(content: Content) -> some View {
        content
            .alert(item.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: item), presenting: item.wrappedValue, actions: { alert in
                alert.buttons
            })
    }
}
