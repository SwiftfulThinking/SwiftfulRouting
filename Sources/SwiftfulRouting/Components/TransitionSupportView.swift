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
        AnyTransitionWithDestination(id: "root", transition: .trailing, destination: { _ in
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
        
    // problem is that when .transition changes, view re-renders and re-appears. Need to update the view's transition but not re-render the view
    
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: selection, items: transitions) { data in
                if data == transitions.first {
                    content
                        .onAppear {
                            print("A")
                        }
                        .transition(
//                            .move(edge: .trailing)
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: TransitionOption.trailingCover.removal
                            )
                        )
//                        .id(data.id + (data.id == selection.id ? currentTransition.rawValue : ""))
//                        .id(data.id + currentTransition.rawValue)
                        .onAppear {
                            print("F")
                        }
                } else {
                    data.destination(router).destination
                        .transition(
//                            .move(edge: .trailing)
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: TransitionOption.trailingCover.removal
                            )
                        )
//                        .id(data.id + (data.id == selection.id ? currentTransition.rawValue : ""))
                }
            }
            .animation(.easeInOut, value: selection.id)
        }
    }
}
