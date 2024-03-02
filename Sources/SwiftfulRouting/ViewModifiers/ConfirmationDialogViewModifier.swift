//
//  ConfirmationDialogViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct ConfirmationDialogViewModifier: ViewModifier {
    
    let option: DialogOption
    let item: Binding<AnyAlert?>

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .confirmationDialog(item.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: Binding(if: option, is: .confirmationDialog, value: item)), titleVisibility: item.wrappedValue?.title.isEmpty ?? true ? .hidden : .visible) {
                    item.wrappedValue?.buttons
                } message: {
                    if let subtitle = item.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
        } else {
            content
                .actionSheet(isPresented: Binding(ifNotNil: item), content: {
                    item.wrappedValue?.actionSheet ?? ActionSheet(title: Text("Error"))
                })
        }
    }
    
}
