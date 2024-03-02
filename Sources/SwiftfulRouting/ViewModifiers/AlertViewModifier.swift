//
//  AlertViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct AlertViewModifier: ViewModifier {
    
    let option: DialogOption
    let item: Binding<AnyAlert?>

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .alert(item.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: Binding(if: option, is: .alert, value: item))) {
                    item.wrappedValue?.buttons
                } message: {
                    if let subtitle = item.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        } else {
            content
                .alert(isPresented: Binding(ifNotNil: item)) {
                    item.wrappedValue?.alert ?? Alert(title: Text("Error"))
                }
        }
    }
}
