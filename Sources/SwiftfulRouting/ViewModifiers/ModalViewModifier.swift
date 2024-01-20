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
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ModalSupportView(allowSimultaneous: true, transitions: items)

//                ZStack {
//                    TransitionSupportView(allowSimultaneous: <#T##Bool#>, transitions: <#T##[(config: ModalConfiguration, destination: AnyDestination)]#>)
//                    
//                    TransitionSupportView(
//                        allowSimultaneous: true,
//                        destinations: [],
//                        transition: .leadingCover // put transition data into item for destinations
//                    )
//                    if let view = item.wrappedValue?.destination {
//                        
//                        if let backgroundColor = configuration.backgroundColor {
//                            backgroundColor
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .edgesIgnoringSafeArea(.all)
//                                .transition(AnyTransition.opacity.animation(configuration.animation))
//                                .onTapGesture {
//                                    item.wrappedValue = nil
//                                }
//                                .zIndex(1)
//                        }
//                        
//                        if let backgroundEffect = configuration.backgroundEffect {
//                            VisualEffectViewRepresentable(effect: backgroundEffect.effect)
//                                .opacity(backgroundEffect.opacity)
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .edgesIgnoringSafeArea(.all)
//                                .transition(AnyTransition.opacity.animation(configuration.animation))
//                                .onTapGesture {
//                                    item.wrappedValue = nil
//                                }
//                                .zIndex(2)
//                        }
//
//                        view
//                            .frame(configuration: configuration)
//                            .edgesIgnoringSafeArea(configuration.useDeviceBounds ? .all : [])
//                            .transition(configuration.transition)
//                            .zIndex(3)
//                    }
//                }
//                .zIndex(999)
//                .animation(configuration.animation, value: item.wrappedValue?.destination == nil)
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


