//
//  ModalViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct ModalViewModifier: ViewModifier {
    
    let configuration: ModalConfiguration
    let item: Binding<AnyDestination?>
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if let view = item.wrappedValue?.destination {
                        if let backgroundColor = configuration.backgroundColor {
                            backgroundColor
                                .edgesIgnoringSafeArea(.all)
                                .transition(AnyTransition.opacity.animation(configuration.animation))
                                .onTapGesture {
                                    item.wrappedValue = nil
                                }
                                .zIndex(1)
                        }

                        view
                            .frame(configuration: configuration)
                            .edgesIgnoringSafeArea(.all)
                            .transition(configuration.transition)
                            .zIndex(2)
                    }
                }
                .zIndex(999)
                .animation(configuration.animation, value: item.wrappedValue?.destination == nil)
            )
    }
}

extension View {
    
    @ViewBuilder func frame(configuration: ModalConfiguration) -> some View {
        if configuration.useDeviceBounds {
            frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: configuration.alignment)
        } else {
            frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
        }
    }
    
}
