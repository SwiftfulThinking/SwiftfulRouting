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
        let _ = Self._printChanges()
        let _ = print("[SR-TSV] body router=\(router.id) txCount=\(transitions.count) lastTxId=\(transitions.last?.id ?? "-") currentTx=\(currentTransition.id) behavior=\(behavior)")
        return ZStack {
            LazyZStack(allowSimultaneous: behavior.allowSimultaneous, selection: transitions.last, items: transitions) { data in
                let dataIndex: Double = Double(transitions.firstIndex(where: { $0.id == data.id }) ?? 99)
                let allowsSwipeBack: Bool = data.transition.canSwipeBack && data.allowsSwipeBack

                let _ = print("[SR-TSV] LazyZStack item router=\(router.id) dataId=\(data.id) isFirst=\(data == transitions.first) dataIndex=\(dataIndex)")

                return Group {
                    if data == transitions.first {
                        content(router)
                    } else {
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
                .transition(
                    .asymmetric(
                        insertion: currentTransition.insertion,
                        removal: .customRemoval(behavior: behavior, direction: currentTransition.reversed, frame: viewFrame)
                    )
                )
                .zIndex(dataIndex)
            }
            // Explicit `.animation(_:value:)` on the LazyZStack. Needed because
            // in complex view trees on iOS 26.x, SwiftUI doesn't reliably apply
            // transaction-based animations (`withAnimation` / `.transaction`)
            // to view insertions inside recursive AnyConditionalView structures.
            // Binding the animation to `transitions.last?.id` gives SwiftUI an
            // explicit diff value to animate against.
            .animation(currentTransition.animation, value: transitions.last?.id)
        }
        // Sniffer BEFORE package's transaction modifier — sees what SwiftUI
        // inherited from the parent view tree. If animation is nil here,
        // SwiftUI already stripped it before reaching our code.
        .transaction { t in
            let router = self.router
            print("[SR-SNIFF-IN] router=\(router.id) parentInheritedAnim=\(String(describing: t.animation)) disables=\(t.disablesAnimations)")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transactionAnimationIfAvailable(
            value: (transitions.last?.id ?? "") + currentTransition.id,
            transition: currentTransition
        )
        // Sniffer AFTER package's transaction modifier — confirms the animation
        // is present on the transaction SwiftUI will actually use to render.
        .transaction { t in
            let router = self.router
            print("[SR-SNIFF-OUT] router=\(router.id) finalAnim=\(String(describing: t.animation)) disables=\(t.disablesAnimations)")
        }
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
                    let prior = transaction.animation
                    transaction.animation = transition.animation
                    print("[SR-TXN] transaction fired value=\(value) priorAnim=\(String(describing: prior)) newAnim=\(String(describing: transition.animation)) transitionId=\(transition.id)")
                }
        } else {
            self.animation(transition.animation, value: value)
        }
    }
    
}
