//
//  AlertViewModifier.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

struct AlertViewModifier: ViewModifier {
    
    let alert: Binding<AnyAlert?>

    func body(content: Content) -> some View {
        content
            .alert(
                alert.wrappedValue?.title ?? "",
                isPresented: Binding(ifAlert: alert, isStyle: .alert),
                actions: {
                    alert.wrappedValue?.buttons
                },
                message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
            )
            .confirmationDialog(
                alert.wrappedValue?.title ?? "",
                isPresented: Binding(ifAlert: alert, isStyle: .confirmationDialog),
                titleVisibility: alert.wrappedValue?.title.isEmpty ?? true ? .hidden : .visible,
                actions: {
                    alert.wrappedValue?.buttons
                },
                message: {
                    if let subtitle = alert.wrappedValue?.subtitle {
                        Text(subtitle)
                    }
                }
            )
    }
}
