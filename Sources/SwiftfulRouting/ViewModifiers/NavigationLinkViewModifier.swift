//
//  NavigationLinkViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct NavigationLinkViewModifier: ViewModifier {
    
    let option: SegueOption
    let item: Binding<AnyDestination?>

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    NavigationLink(isActive: Binding(ifNotNil: Binding(if: option, is: .push, value: item))) {
                        ZStack {
                            if let view = item.wrappedValue?.destination {
                                view
                            }
                        }
                    } label: {
                        EmptyView()
                    }
                }
            )
    }
}
