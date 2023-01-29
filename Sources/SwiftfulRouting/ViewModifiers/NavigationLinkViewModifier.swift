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
    let items: Binding<[AnyDestination]>

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .navigationDestination(for: AnyDestination.self) { value in
                    value.destination
                }
                .onAppear {
                    print("ADDING ANOTHER NAVDEST")
                }
        } else {
            content
                .background(
                    ZStack {
                        NavigationLink(isActive: Binding(ifNotNil: Binding(if: option, is: .push, value: Binding(toLastElementIn: items)))) {
                            if let view = items.wrappedValue.last?.destination {
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
