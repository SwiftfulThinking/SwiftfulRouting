//
//  TransitionSupportView.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI
import SwiftfulRecursiveUI

struct TransitionSupportView<Content:View>: View {
    
    var behavior: TransitionMemoryBehavior = .keepPrevious
    let router: AnyRouter
    let transitions: [AnyTransitionDestination]
    @ViewBuilder var content: (AnyRouter) -> Content
    let currentTransition: TransitionOption
    let onDidSwipeBack: () -> Void

    @State private var viewFrame: CGRect = UIScreen.main.bounds

    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: true, selection: transitions.last, items: transitions) { data in
                let dataIndex: Double = Double(transitions.firstIndex(where: { $0.id == data.id }) ?? 99)
                let allowsSwipeBack: Bool = data.transition.canSwipeBack && data.allowsSwipeBack
                
                if data == transitions.first {
                    return content(router)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).animation(.easeInOut),
                                removal: .move(edge: .leading).animation(.easeInOut)
                            )
                        )
                        .zIndex(dataIndex)
                        .animation(currentTransition.animation, value: (transitions.last?.id ?? "") + currentTransition.id)

                } else {
//                        if allowsSwipeBack {
//                            SwipeBackSupportContainer(
//                                insertionTransition: data.transition,
//                                swipeThreshold: 30,
//                                content: {
//                                    AnyView(data.destination(router))
//                                },
//                                onDidSwipeBack: onDidSwipeBack
//                            )
//                        } else {
                    return AnyView(data.destination(router))
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).animation(.easeInOut),
                                removal: .move(edge: .leading).animation(.easeInOut)
                            )
                        )
                        .zIndex(dataIndex)
                        .animation(currentTransition.animation, value: (transitions.last?.id ?? "") + currentTransition.id)

//                        }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(currentTransition.animation, value: (transitions.last?.id ?? "") + currentTransition.id)
//        .transactionAnimationIfAvailable(
//            value: (transitions.last?.id ?? "") + currentTransition.id,
//            transition: currentTransition
//        )
//        .animation(currentTransition.animation, value: (transitions.last?.id ?? "") + currentTransition.id)
//        .ifSatisfiesCondition(viewFrame == .zero, transform: { content in
//            content
//                .readingFrame(onChange: { frame in
//                    // Add +150 to account for safe areas
//                    self.viewFrame = frame
////                    self.viewFrame = UIScreen.main.bounds
////                    self.viewFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
//                })
//        })
    }
}

extension View {
    
    @ViewBuilder
    func transactionAnimationIfAvailable<T: Equatable>(value: T, transition: TransitionOption) -> some View {
        if #available(iOS 17.0, *) {
            self
                .transaction(value: value) { transaction in
                    transaction.animation = transition.animation
                }
        } else {
            self.animation(transition.animation, value: value)
        }
    }
    
}
