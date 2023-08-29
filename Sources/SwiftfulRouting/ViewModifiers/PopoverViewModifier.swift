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
    
    let anchor: PopoverAttachmentAnchor
    let screen: Binding<AnyDestination?>

    func body(content: Content) -> some View {
        content
            .popover(
                isPresented: Binding(ifNotNil: screen),
                attachmentAnchor: anchor,
                arrowEdge: .bottom) {
                    if let view = screen.wrappedValue?.destination {
                        view
                            .presentationCompactAdaptation(.popover)
                    }
                }
    }
    
}

/*
 Text("This is a popover 😎")
     .padding()

 */
