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
                                removal: .customRemoval(direction: currentTransition.reversed)
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
                                removal: .customRemoval(direction: currentTransition.reversed)
                            )
                        )
//                        .id(data.id + (data.id == selection.id ? currentTransition.rawValue : ""))
                }
            }
            .animation(.easeInOut, value: selection.id)
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
//            .overlay(
//                Text(frame.debugDescription)
//                    .foregroundColor(.white)
//            )
//            .offset(x: x, y: y)
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
                .ignoresSafeArea()
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
public extension View {
    
    /// Get the frame of the View
    ///
    /// Adds a GeometryReader to the background of a View.
    func readingFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ frame: CGRect) -> ()) -> some View {
        background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
}
