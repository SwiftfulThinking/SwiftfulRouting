//
//  FullScreenCoverViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

@available(iOS 14.0, *)
struct FullScreenCoverViewModifier: ViewModifier {
    
    let option: SegueOption
    let items: Binding<[AnyDestination]>

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: Binding(if: option, is: .fullScreenCover, value: bindingToLastElement(in: items)), onDismiss: nil) { _ in
                ZStack {
                    if let view = items.last?.wrappedValue.destination {
                        view
                    }
                }
            }
    }
}
