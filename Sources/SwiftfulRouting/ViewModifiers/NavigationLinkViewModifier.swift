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
    let screens: Binding<[AnyDestination]>
    
    // Must be @State so that this modifier can control the state & not add .navigationDestination twice
    @State var shouldAddNavigationDestination: Bool

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            // If we are continuing an existing stack, don't need to add another .navigationDestination modifier
            if shouldAddNavigationDestination {
                ZStack {
                    content
                }
                .navigationDestination(for: AnyDestination.self) { value in
                    value.destination
                }
            } else {
                content
            }
        } else {
            content
                .background(
                    ZStack {
                        NavigationLink(isActive: Binding(ifNotNil: Binding(if: option, is: .push, value: Binding(toLastElementIn: screens)))) {
                            if let view = screens.wrappedValue.last?.destination {
                                view
                            }
                        } label: {
                            EmptyView()
                        }
                    }
                )
        }
    }
}
