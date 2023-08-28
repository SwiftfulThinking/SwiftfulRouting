//
//  PopoverViewModifier.swift
//  
//
//  Created by Nick Sarno on 8/28/23.
//

import Foundation
import SwiftUI

@available(iOS 16.4, *)
struct PopoverViewModifier: ViewModifier {
    
    let option: PopoverOption
    let screen: Binding<AnyDestination?>

    func body(content: Content) -> some View {
        content
            .popover(
                isPresented: Binding(ifNotNil: screen),
                attachmentAnchor: option.attachmentAnchor,
                arrowEdge: .bottom) {
                    if let view = screen.wrappedValue?.destination {
                        view
                            .presentationCompactAdaptation(
                                horizontal: option.horizontalAdaptation,
                                vertical: option.verticalAdaptation
                            )
                    }
                }
    }
    
}
