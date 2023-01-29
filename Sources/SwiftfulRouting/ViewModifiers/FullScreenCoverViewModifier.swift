//
//  FullScreenCoverViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct FullScreenCoverViewModifier: ViewModifier {
    
    let option: SegueOption
    let screens: Binding<[AnyDestination]>

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content
                .fullScreenCover(item: Binding(if: option, is: .fullScreenCover, value: Binding(toLastElementIn: screens)), onDismiss: nil) { _ in
                    if let view = screens.wrappedValue.last?.destination {
                        view
                    }
                }
        } else {
            content
                .sheet(item: Binding(if: option, is: .fullScreenCover, value: Binding(toLastElementIn: screens)), onDismiss: nil) { destination in
                    if let view = screens.wrappedValue.last?.destination {
                        view
                    }
                }
        }
    }
}
