//
//  File.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

@available (iOS 15, *)
struct ConfirmationDialogViewModifier: ViewModifier {
    
    let item: Binding<AnyAlert?>

    func body(content: Content) -> some View {
        content
            .confirmationDialog(item.wrappedValue?.title ?? "", isPresented: Binding(ifNotNil: item), titleVisibility: item.wrappedValue?.title.isEmpty ?? true ? .hidden : .visible, actions: {
                item.wrappedValue?.buttons
            })
    }
    
}
