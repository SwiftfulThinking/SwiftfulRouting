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
    let screens: Binding<[AnyDestination]>
    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: Binding(if: option, is: .fullScreenCover, value: Binding(toLastElementIn: screens)), onDismiss: onDismiss) { _ in
                if let view = screens.wrappedValue.last?.destination {
                    view
                }
            }
    }
}
