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
    let destination: (AnyRouter) -> AnyDestination
    
//    init<T:View>(id: String, transition: TransitionOption = .trailing, destination: (AnyRouter) -> T) {
//        self.id = id
//        self.transition = transition
//        self.destination = AnyDestination(destination(<#AnyRouter#>))
//    }
    
    static var root: AnyTransitionWithDestination {
        AnyTransitionWithDestination(id: "root", destination: { _ in
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
                    content
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: currentTransition.removal
                            )
                        )
                } else {
                    data.destination(router).destination
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: currentTransition.removal
                            )
                        )
                }
            }
            .animation(.easeInOut, value: selection.id)
        }
//        .onFirstAppear {
//            selection = transitions.last
//        }
        .onChange(of: transitions, perform: { newValue in
//            Task { @MainActor in
//                try? await Task.sleep(nanoseconds: 0)
//                if let new = newValue.last(where: { !$0.didDismiss }), self.selection?.id != new.id {
//                    self.selection = new
                    print("on change to : \(selection.id)")
//                }
//            }
        })
    }
}
