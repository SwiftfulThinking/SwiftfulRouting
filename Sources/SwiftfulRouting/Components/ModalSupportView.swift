//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/19/24.
//

import Foundation
import SwiftUI

struct AnyModalWithDestination: Identifiable, Equatable {
    let id: String
    let configuration: ModalConfiguration
    let destination: AnyDestination
    private(set) var didDismiss: Bool = false
    
    static func == (lhs: AnyModalWithDestination, rhs: AnyModalWithDestination) -> Bool {
        lhs.id == rhs.id && lhs.didDismiss == rhs.didDismiss
    }
    
    mutating func dismiss() {
        didDismiss = true
    }
    
    static var origin: AnyModalWithDestination {
        AnyModalWithDestination(
            id: "origin",
            configuration: ModalConfiguration(
                transition: .identity,
                animation: .default,
                alignment: .center,
                backgroundColor: nil,
                ignoreSafeArea: true
            ),
            destination: AnyDestination(EmptyView())
        )
    }
}

struct ModalSupportView: View {
    
    @State private var selection: AnyModalWithDestination? = nil

    let transitions: [AnyModalWithDestination]
    let onDismissModal: (AnyModalWithDestination) -> Void
        
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: true, selection: selection, items: transitions) { data in
                LazyZStack(allowSimultaneous: true, selection: true) { showView1 in
                    if showView1 {
                        data.destination.destination
                            .frame(configuration: data.configuration)
                            .transition(data.configuration.transition)
                            .zIndex(2)
                    } else {
                        if let backgroundColor = data.configuration.backgroundColor {
                            backgroundColor
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .edgesIgnoringSafeArea(.all)
                                .transition(AnyTransition.opacity.animation(.easeInOut))
                                .onTapGesture {
                                    onDismissModal(data)
                                }
                                .zIndex(1)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            .animation(transitions.last?.configuration.animation ?? .default, value: selection?.id)
        }
        .onFirstAppear {
            selection = transitions.last
        }
        .onChange(of: transitions, perform: { newValue in
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 0)
                if let new = newValue.last(where: { !$0.didDismiss }), self.selection?.id != new.id {
                    self.selection = new
                    print("on change to : \(new.id)")
                }
            }
        })
    }
}

public enum TransitionOption: String, CaseIterable {
    case trailing, trailingCover, leading, leadingCover, top, topCover, bottom, bottomCover, scale, opacity, identity, slide, slideCover
    
    var insertion: AnyTransition {
        switch self {
        case .trailing, .trailingCover:
            return .move(edge: .trailing)
        case .leading, .leadingCover:
            return .move(edge: .leading)
        case .top, .topCover:
            return .move(edge: .top)
        case .bottom, .bottomCover:
            return .move(edge: .bottom)
        case .scale:
            return .scale.animation(.default)
        case .opacity:
            return .opacity.animation(.default)
        case .slide, .slideCover:
            return .slide.animation(.default)
        case .identity:
            return .identity
        }
    }
    
    var removal: AnyTransition {
        switch self {
        case .trailingCover, .leadingCover, .topCover, .bottomCover, .slideCover:
            return AnyTransition.opacity.animation(.easeInOut.delay(1))
        case .trailing:
            return .move(edge: .leading)
        case .leading:
            return .move(edge: .trailing)
        case .top:
            return .move(edge: .bottom)
        case .bottom:
            return .move(edge: .top)
        case .scale:
            return .scale.animation(.easeInOut)
        case .opacity:
            return .opacity.animation(.easeInOut)
        case .slide:
            return .slide.animation(.easeInOut)
        case .identity:
            return .identity

        }
    }
}

