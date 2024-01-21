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
    let destination: AnyDestination
    
    static var root: AnyTransitionWithDestination {
        AnyTransitionWithDestination(
            id: "root",
            transition: .identity,
            destination: AnyDestination(EmptyView())
        )
    }
}

struct TransitionSupportView<Content:View>: View {
    
    @Binding var selection: AnyTransitionWithDestination?
    let transitions: [AnyTransitionWithDestination]
    @ViewBuilder var content: Content
        
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: selection, items: transitions) { data in
                if data == transitions.first {
                    content
                        .transition(
                            .asymmetric(
                                insertion: data.transition.insertion,
                                removal: data.transition.removal
                            )
                        )
                } else {
                    data.destination.destination
                        .transition(
                            .asymmetric(
                                insertion: data.transition.insertion,
                                removal: data.transition.removal
                            )
                        )
                }
            }
            .animation(.easeInOut, value: selection?.id)
        }
        .onFirstAppear {
            selection = transitions.last
        }
//        .onChange(of: transitions, perform: { newValue in
//            Task { @MainActor in
//                try? await Task.sleep(nanoseconds: 0)
//                if let new = newValue.last(where: { !$0.didDismiss }), self.selection?.id != new.id {
//                    self.selection = new
//                    print("on change to : \(new.id)")
//                }
//            }
//        })
    }
}
