//
//  TransitionSupportView.swift
//
//
//  Created by Nick Sarno on 1/20/24.
//

import Foundation
import SwiftUI
import SwiftfulRecursiveUI

struct AnyTransitionWithDestination: Identifiable, Equatable {
    let id: String
    let transition: TransitionOption
    let destination: (AnyRouter) -> AnyDestination
    //
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
    let allowSimultaneous: Bool
    let allowsSwipeBack: Bool
    let currentTransition: TransitionOption
    let transitions: [AnyTransitionWithDestination]
    @Binding var selection: AnyTransitionWithDestination
    @ViewBuilder var content: (AnyRouter) -> Content
    let onDidSwipeBack: () -> Void
    
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: allowSimultaneous, selection: selection, items: transitions) { data in
                if data == transitions.first {
                    content(router)
                        .transition(
                            .asymmetric(
                                insertion: currentTransition.insertion,
                                removal: .customRemoval(direction: currentTransition.reversed)
                            )
                        )
                        .zIndex(1)
                } else {
                    Group {
                        if allowsSwipeBack {
                            SwipeBackSupportContainer(
                                insertionTransition: data.transition,
                                swipeThreshold: 30,
                                content: {
                                    data.destination(router).destination
                                },
                                onDidSwipeBack: onDidSwipeBack
                            )
                        } else {
                            data.destination(router).destination
                        }
                    }
                    .transition(
                        .asymmetric(
                            insertion: currentTransition.insertion,
                            removal: .customRemoval(direction: currentTransition.reversed)
                        )
                    )
                    .zIndex(Double(transitions.firstIndex(of: data) ?? 1) + 1)
                }
            }
            .animation(.easeInOut, value: selection.id)
        }
    }
}

public protocol TransitionSupportRouter {
    func showTransition<T>(transition: TransitionOption, destination: @escaping (AnyRouter) -> T) where T : View
    func dismissTransition()
    var isRootView: Bool { get }
}

public struct TransitionSupportViewBuilder<Content: View>: View, TransitionSupportRouter {
    
    let router: AnyRouter
    let allowSimultaneous: Bool
    let allowsSwipeBack: Bool
    @State private var screens: [AnyTransitionWithDestination] = [.root]
    @State private var selectedScreen: AnyTransitionWithDestination = .root
    @State private var currentTransition: TransitionOption = .trailing
    @ViewBuilder var content: (TransitionSupportRouter) -> Content
    
    public init(router: AnyRouter, allowsSwipeBack: Bool = true, allowSimultaneous: Bool = true, content: @escaping (TransitionSupportRouter) -> Content) {
        self.router = router
        self.allowsSwipeBack = allowsSwipeBack
        self.allowSimultaneous = allowSimultaneous
        self.content = content
    }

    public var body: some View {
        TransitionSupportView(
            router: router,
            allowSimultaneous: allowSimultaneous,
            allowsSwipeBack: allowsSwipeBack,
            currentTransition: currentTransition,
            transitions: screens,
            selection: $selectedScreen,
            content: { router in
                content(self)
            },
            onDidSwipeBack: {
                dismissTransition()
            }
        )
    }
    
    public var isRootView: Bool {
        screens.count < 2
    }
    
    public func showTransition<T>(transition: TransitionOption, destination: @escaping (AnyRouter) -> T) where T : View {
        let new = AnyTransitionWithDestination(
            id: UUID().uuidString,
            transition: transition,
            destination: { router in
                AnyDestination(destination(router))
            }
        )
        
        self.currentTransition = transition
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000)
            
            self.screens.append(new)
            self.selectedScreen = new
        }
    }
    
    public func dismissTransition() {
        let uid = UUID().uuidString
        print("\(uid) DISMISS START")

        if let index = screens.firstIndex(where: { $0.id == selectedScreen.id }), screens.indices.contains(index - 1) {
            self.currentTransition = screens[index].transition.reversed
            print("\(uid) DISMISS 1: \(screens.count)")

            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 100_000_000)
                
                selectedScreen = screens[index - 1]
                print("\(uid) DISMISS 2: \(screens.count)")

                try? await Task.sleep(nanoseconds: 25_000)
                screens.remove(at: index)
                print("\(uid) DISMISS 3: \(screens.count)")

            }
        }
    }
    
    // MARK: TODO - dismiss by id
//    func dismissAllTransitions() {
//        
//    }
    
//    func dismissTransition(id: String?) {
//        
//        func dismissScreen(atIndex index: Int) {
//            self.currentTransition = screens[index].transition.reversed
//            
//            Task { @MainActor in
//                try? await Task.sleep(nanoseconds: 100_000_000)
//                
//                selectedScreen = screens[index - 1]
//                
//                try? await Task.sleep(nanoseconds: 25_000)
//                screens.remove(at: index)
//            }
//        }
//        
//        if let id {
//            // Dismiss to screen at id and show screen before it
//            if let index = screens.firstIndex(where: { $0.id == id }), screens.indices.contains(index - 1) {
//                dismissScreen(atIndex: index)
//            }
//        } else {
//            // Dismiss selectedScreen
//            if let index = screens.firstIndex(where: { $0.id == selectedScreen.id }), screens.indices.contains(index - 1) {
//                dismissScreen(atIndex: index)
//            }
//        }
//    }
}

#Preview {
    RouterView { router in
        TransitionSupportViewBuilder(router: router, allowSimultaneous: true) { subRouter in
            Rectangle()
                .fill(Color.pink)
                .onTapGesture {
                    let bool = Int.random(in: 0..<4) == 1
                    
                    if bool {
                        subRouter.dismissTransition()
                    } else {
                        subRouter.showTransition(transition: .trailingCover, destination: { _ in
                            Rectangle()
                                .fill(Color.blue)
                                .onTapGesture {
                                    subRouter.dismissTransition()
                                }
                        })
                    }
                }
        }
    }
}

struct CustomRemovalTransition: ViewModifier {
    let option: TransitionOption?
    @State private var frame: CGRect = .zero

    func body(content: Content) -> some View {
        content
            .readingFrame { frame in
                self.frame = frame
            }
            .offset(x: xOffset, y: yOffset)
    }
    
    private var xOffset: CGFloat {
        switch option {
        case .trailing:
            return frame.width
        case .trailingCover:
            return 0
        case .leading:
            return -frame.width
        case .leadingCover:
            return 0
        case .top:
            return 0
        case .topCover:
            return 0
        case .bottom:
            return 0
        case .bottomCover:
            return 0
        case nil:
            return 0
        }
    }
    
    private var yOffset: CGFloat {
        switch option {
        case .trailing:
            return 0
        case .trailingCover:
            return 0
        case .leading:
            return 0
        case .leadingCover:
            return 0
        case .top:
            return -frame.height
        case .topCover:
            return 0
        case .bottom:
            return frame.height
        case .bottomCover:
            return 0
        case nil:
            return 0
        }
    }
}

extension AnyTransition {
    
    static func customRemoval(direction: TransitionOption) -> AnyTransition {
        .modifier(
            active: CustomRemovalTransition(option: direction),
            identity: CustomRemovalTransition(option: nil)
        )
    }
    
}

@available(iOS 14, *)
/// Adds a transparent View and read it's frame.
///
/// Adds a GeometryReader with infinity frame.
public struct FrameReader: View {
    
    let coordinateSpace: CoordinateSpace
    let onChange: (_ frame: CGRect) -> Void
    
    public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ frame: CGRect) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.onChange = onChange
    }

    public var body: some View {
        GeometryReader { geo in
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear(perform: {
                    onChange(geo.frame(in: coordinateSpace))
                })
                .onChange(of: geo.frame(in: coordinateSpace), perform: onChange)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

@available(iOS 14, *)
extension View {
    
    /// Get the frame of the View
    ///
    /// Adds a GeometryReader to the background of a View.
    func readingFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ frame: CGRect) -> ()) -> some View {
        background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
}
