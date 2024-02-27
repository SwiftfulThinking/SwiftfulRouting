//
//  ModalViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//
import SwiftUI

struct ModalViewModifier: ViewModifier {
    
    let items: [AnyModalWithDestination]
    let onDismissModal: (AnyModalWithDestination) -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ModalSupportView(transitions: items, onDismissModal: onDismissModal)
            )
    }
}

extension View {
    
    @ViewBuilder func frame(configuration: ModalConfiguration) -> some View {
        if configuration.ignoreSafeArea {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
                .ignoresSafeArea()
        } else {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
        }
    }
    
}
