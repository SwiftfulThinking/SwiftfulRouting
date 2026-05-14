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
            LazyZStack(allowSimultaneous: behavior.allowSimultaneous, selection: transitions.last, items: transitions) { data in
                let dataIndex: Double = Double(transitions.firstIndex(where: { $0.id == data.id }) ?? 99)
                let allowsSwipeBack: Bool = data.transition.canSwipeBack && data.allowsSwipeBack
                
                return Group {
                    if data == transitions.first {
                        content(router)
                    } else {
                        ManualInsertionSlide(
                            option: currentTransition,
                            frame: viewFrame,
                            animation: currentTransition.animation
                        ) {
                            if allowsSwipeBack {
                                SwipeBackSupportContainer(
                                    insertionTransition: data.transition,
                                    swipeThreshold: 30,
                                    content: {
                                        AnyView(data.destination(router))
                                    },
                                    onDidSwipeBack: onDidSwipeBack
                                )
                            } else {
                                AnyView(data.destination(router))
                            }
                        }
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: .identity,
                        removal: .customRemoval(behavior: behavior, direction: currentTransition.reversed, frame: viewFrame)
                    )
                )
                .zIndex(dataIndex)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transactionAnimationIfAvailable(
            value: (transitions.last?.id ?? "") + currentTransition.id,
            transition: currentTransition
        )
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

// Workaround: on iOS 26, SwiftUI at the root host skips applying the active state
// of an inserted view's `.transition`. Drive the slide-in via @State + .onAppear
// + withAnimation so SwiftUI just animates a state change on an already-rendered
// view, bypassing the broken insertion-transition pipeline.
private struct ManualInsertionSlide<Content: View>: View {
    let option: TransitionOption
    let frame: CGRect
    let animation: Animation?
    @ViewBuilder let content: () -> Content

    @State private var hasSlidIn: Bool = false

    var body: some View {
        content()
            .offset(
                x: hasSlidIn ? 0 : initialXOffset,
                y: hasSlidIn ? 0 : initialYOffset
            )
            .animation(animation, value: hasSlidIn)
            .onAppear {
                hasSlidIn = true
            }
    }

    private var initialXOffset: CGFloat {
        switch option {
        case .trailing: return frame.width
        case .leading:  return -frame.width
        default:        return 0
        }
    }

    private var initialYOffset: CGFloat {
        switch option {
        case .top:    return -frame.height
        case .bottom: return frame.height
        default:      return 0
        }
    }
}
