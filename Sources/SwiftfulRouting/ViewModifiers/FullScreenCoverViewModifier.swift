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
    let item: Binding<AnyDestination?>

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: Binding(if: option, is: .fullScreenCover, value: item), onDismiss: nil) { destination in
                NavigationView {
                    if let view = item.wrappedValue?.destination {
                        view
                    }
                }
            }
    }
}
