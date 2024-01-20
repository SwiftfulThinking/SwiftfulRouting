//
//  ModalViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct ModalViewModifier: ViewModifier {
    
    let items: [AnyModalWithDestination]
    let onDismissModal: (AnyModalWithDestination) -> Void
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ModalSupportView(allowSimultaneous: true, transitions: items, onDismissModal: onDismissModal)
            )
    }
}

extension View {
    
    @ViewBuilder func frame(configuration: ModalConfiguration) -> some View {
        if configuration.useDeviceBounds {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
                .ignoresSafeArea()
                .onAppear {
                    print("IGNORING")
                }
        } else {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
                .onAppear {
                    print("DONT IGNORE")
                }
        }
    }
    
}


