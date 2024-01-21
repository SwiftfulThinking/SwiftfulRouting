//
//  TransitionSupportView.swift
//
//
//  Created by Nick Sarno on 1/20/24.
//

import Foundation
import SwiftUI

struct AnyTransitionWithDestination: Identifiable, Equatable {
    let id: String
    let transition: TransitionOption
    let destination: (AnyRouter) -> AnyDestination
    
    static var root: AnyTransitionWithDestination {
        AnyTransitionWithDestination(id: "root", transition: .identity, destination: { _ in
            AnyDestination(EmptyView())
        })
    }
    
    static func == (lhs: AnyTransitionWithDestination, rhs: AnyTransitionWithDestination) -> Bool {
        lhs.id == rhs.id
    }

}

struct TransitionSupportView<Content:View>: View {
    
    let router: AnyRouter
    @Binding var selection: AnyTransitionWithDestination
    let transitions: [AnyTransitionWithDestination]
    @ViewBuilder var content: Content
    let currentTransition: TransitionOption
        
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: selection, items: transitions) { data in
                if data == transitions.first {
                    ZStack {
                        Text("Hello")
                        content
                    }
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: currentTransition.removal
                            )
                        )
                        .id(data.id + currentTransition.rawValue)
                } else {
                    data.destination(router).destination
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: currentTransition.removal
                            )
                        )
                        .id(data.id + currentTransition.rawValue)
                }
            }
            .animation(.easeInOut, value: selection.id)
        }
    }
}
