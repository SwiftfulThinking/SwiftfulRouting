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
    @EnvironmentObject private var topRouter: TopRouter

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    NavigationLink(isActive: Binding(ifNotNil: Binding(if: option, is: .push, value: item))) {
                        SubRouterView {
                            if let view = item.wrappedValue?.destination {
                                view
                                    .environmentObject(topRouter)
                            }
                        }
                    } label: {
                        EmptyView()
                    }
                }
            )
    }
}
