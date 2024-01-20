//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/19/24.
//

import Foundation
import SwiftUI

struct AnyModalWithDestination: Identifiable, Equatable {
    let id = UUID().uuidString
    let configuration: ModalConfiguration
    let destination: AnyDestination
    
    static func == (lhs: AnyModalWithDestination, rhs: AnyModalWithDestination) -> Bool {
        lhs.id == rhs.id
    }
}

struct ModalSupportView: View {
    
    @State private var selection: AnyModalWithDestination? = nil

    let allowSimultaneous: Bool
    let transitions: [AnyModalWithDestination]
    let onDismissModal: (AnyModalWithDestination) -> Void
    @State private var showSelection: Bool = true
    
    var currentTransition: TransitionOption {
        transitions.last?.configuration.transition ?? .slide
    }
    
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: allowSimultaneous, selection: selection, items: transitions) { data in
                LazyZStack(allowSimultaneous: true, selection: true) { showView1 in
                    if showView1 {
                        if showSelection {
                            data.destination.destination
                                .id(data.id + currentTransition.rawValue)
                                .transition(data.configuration.transition.insertion)
                                .animation(data.configuration.animation, value: selection?.id)
                        } else {
                            EmptyView()
                        }
                    } else {
                        if let backgroundColor = data.configuration.backgroundColor {
                            backgroundColor
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .edgesIgnoringSafeArea(.all)
                                .transition(AnyTransition.opacity.animation(.easeInOut))
                                .animation(data.configuration.animation, value: selection?.id)
                                .onTapGesture {
//                                    onDismissModal(data)
                                    showSelection = false
                                }
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
                selection = newValue.last
            }
        })
    }
}

public enum TransitionOption: String {
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
            return .identity
        case .trailing:
            return .move(edge: .leading)
        case .leading:
            return .move(edge: .trailing)
        case .top:
            return .move(edge: .bottom)
        case .bottom:
            return .move(edge: .top)
        case .scale:
            return .scale.animation(.default)
        case .opacity:
            return .opacity.animation(.default)
        case .slide:
            return .slide.animation(.default)
        case .identity:
            return .identity

        }
    }
}


import Foundation
import SwiftUI

// Notes:
// 1. ParentView - The implementation
// 2. AnyRecursiveView - Takes an array and makes it recursive
// 3. RecursiveView - Takes recursive data and displays it
// 4. AnyConditionalView - 2 items in a ZStack
// 5. View - has the transition

public typealias LazyZStack = AnyRecursiveView

public struct AnyRecursiveView<T:Identifiable>: View {
    
    let allowSimultaneous: Bool
    let selection: T?
    let items: [T]
    let recursiveItem: AnyRecursiveModel<T>?
    let view: (T) -> any View
    
    public init(allowSimultaneous: Bool, selection: T?, items: [T], view: @escaping (T) -> any View) {
        self.allowSimultaneous = allowSimultaneous
        self.selection = selection
        self.items = items
        self.recursiveItem = try? items.asAnyRecursiveModelWithDepthOfOne()
        self.view = view
    }

    public init(allowSimultaneous: Bool, selection: T?, items: Range<T>, view: @escaping (T) -> any View) where T : IntegerIdentifiable {
        self.allowSimultaneous = allowSimultaneous
        self.selection = selection
        let array: [T] = Array(range: items)
        self.items = array
        self.recursiveItem = try? array.asAnyRecursiveModelWithDepthOfOne()
        self.view = view
    }
    
    public init(allowSimultaneous: Bool, selection: Bool?, view: @escaping (T) -> any View) where T : BoolIdentifiable {
        self.allowSimultaneous = allowSimultaneous
        self.selection = .init(id: selection ?? false)
        let array: [T] = [.init(id: false), .init(id: true)]
        self.items = array
        self.recursiveItem = try? array.asAnyRecursiveModelWithDepthOfOne()
        self.view = view
    }

    public var body: some View {
        AnyConditionalView(
            removePrevious: !allowSimultaneous,
            showView1: selection?.id == items.first?.id,
            view1: {
                if let item = items.first {
                    AnyView(view(item))
                } else {
                    EmptyView()
                }
            },
            view2: {
                RecursiveView(
                    removePrevious: !allowSimultaneous,
                    selection: selection,
                    items: recursiveItem?.children ?? [],
                    view: { value in
                        AnyView(view(value.value))
                    }
                )
            }
        )
    }
}

struct RecursiveView<T:Identifiable>: View {
    
    let removePrevious: Bool
    let selection: T?
    let items: [AnyRecursiveModel<T>]
    let view: (AnyRecursiveModel<T>) -> any View
    
    var body: some View {
        AnyConditionalView(
            removePrevious: removePrevious,
            showView1: selection?.id == items.first?.id,
            view1: {
                if let item = items.first {
                    AnyView(view(item))
                } else {
                    EmptyView()
                }
            },
            view2: {
                if let children = items.first?.children {
                    RecursiveView(
                        removePrevious: removePrevious,
                        selection: selection,
                        items: children,
                        view: { value in
                            AnyView(view(value))
                        }
                    )
                } else {
                    EmptyView()
                }
            }
        )
    }
}

/// A view displays one of two views based on a Boolean
struct AnyConditionalView: View {
    
    var removePrevious: Bool = false
    let showView1: Bool
    let view1: () -> any View
    let view2: () -> any View
    
    var body: some View {
        if showView1 || !removePrevious {
            AnyView(view1())
        }
        if !showView1 {
            AnyView(view2())
        }
    }
}


// MARK: IntegerIdentifiable

public protocol IntegerIdentifiable: Identifiable where ID == Int {
    var id: Int { get }
    init(id: Int)
}

extension Int: IntegerIdentifiable {
    public var id: Int {
        self
    }
    public init(id: Int) {
        self = id
    }
}

extension Array {
    init(range: Range<Element>) where Element : Identifiable, Element : IntegerIdentifiable {
        self.init((range.lowerBound.id...range.upperBound.id).map { id in
            Element(id: id)
        })
    }
}

// MARK: BoolIdentifiable
public protocol BoolIdentifiable: Identifiable where ID == Bool {
    var id: Bool { get }
    init(id: Bool)
}

extension Bool: BoolIdentifiable {
    public var id: Bool {
        self
    }
    public init(id: Bool) {
        self = id
    }
}

// MARK: PREVIEW

fileprivate struct PreviewView: View {
    struct Item: Identifiable {
        var id: String {
            text
        }
        let text: String
    }
    
    @State private var selection: Item? = nil
    @State var questions = [
        Item(text: "one"),
        Item(text: "two"),
        Item(text: "three"),
        Item(text: "four"),
    ]
    
    var selectedIndex: Int {
        questions.firstIndex(where: { $0.id == selection?.id }) ?? 0
    }
        
    var body: some View {
        ZStack {
            // ParentView
            VStack(spacing: 20) {
                // Example using Bool
                AnyRecursiveView(allowSimultaneous: true, selection: selectedIndex == 0) { value in
                    // View
                    Rectangle()
                        .fill(value ? Color.red : Color.green)
                        .overlay(
                            Text(value.description)
                        )
                        .transition(AnyTransition.opacity)
                }
                
                // Example using Bool
                LazyZStack(allowSimultaneous: true, selection: selectedIndex == 0) { (value: Bool) in
                    // View
                    if value {
                        Rectangle()
                            .fill(Color.red)
                            .overlay(
                                Text(value.description)
                            )
                            .transition(AnyTransition.slide)
                    } else {
                        Rectangle()
                            .fill(Color.green)
                            .overlay(
                                Text(value.description)
                            )
                            .transition(AnyTransition.slide)
                    }
                }
                
                // Example using Int
                AnyRecursiveView(allowSimultaneous: true, selection: selectedIndex, items: 0..<4) { value in
                    // View
                    Rectangle()
                        .fill(
                            value == 1 ? Color.red :
                            value == 2 ? Color.blue :
                            value == 3 ? Color.orange :
                            Color.yellow
                        )
                        .overlay(
                            Text("\(value)")
                        )
                        .transition(AnyTransition.slide)
                }

                // Example using Identifiable
                AnyRecursiveView(allowSimultaneous: true, selection: selection, items: questions) { value in
                    Rectangle()
                        .fill(
                            value.text == "one" ? Color.red :
                                value.text == "two" ? Color.blue :
                                value.text == "three" ? Color.orange :
                                value.text == "four" ? Color.green :
                                Color.yellow
                        )
                        .overlay(
                            Text(value.text)
                        )
                        .transition(AnyTransition.scale)
                }
            }
        }
        .animation(.linear, value: selection?.id)
        .onTapGesture {
            if let selection, let index = questions.firstIndex(where: { $0.id == selection.id }),
               questions.indices.contains(index + 1) {
                self.selection = questions[index + 1]
            } else {
                selection = questions.first
            }
        }
        .onAppear {
            selection = questions.first
        }
    }
}

//#Preview {
//    PreviewView()
//}


import Foundation

/// A data model that contains itself, and a child array of it's own Type
struct AnyRecursiveModel<Value:Identifiable>: Hashable, Identifiable {
    var id: AnyHashable
    var value: Value
    var children: [AnyRecursiveModel<Value>]?
    
    init(value: Value) {
        self.id = value.id
        self.value = value
        self.children = nil
    }

    static func == (lhs: AnyRecursiveModel<Value>, rhs: AnyRecursiveModel<Value>) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    mutating func appendingChild(_ child: AnyRecursiveModel<Value>) {
        children = (children ?? []) + [child]
    }
}

extension Array where Element : Identifiable {
    
    /// Convert any array into AnyRecursiveModel, where Value is the first element in the Array
    ///
    /// For exampel:
    ///
    /// - let array = [1,2,3, 4, 5, 6]
    /// - let newValue = array.asAnyRecursiveModel()
    /// - then newValue will be:
    /// - let newValue [(1, [(2, [(3, [(4, [(5, [])])])])])]
    ///
    func asAnyRecursiveModelWithDepthOfOne() throws -> AnyRecursiveModel<Element> {
        let items = self
        
        guard let first = items.first else {
            throw URLError(.dataNotAllowed)
        }
        
        var remainingItems: [Element] = items
        
        var object = AnyRecursiveModel(value: first)
        
        remainingItems.remove(at: 0)
        let children = remainingItems.asArrayOfAnyRecursiveModelWithDepthOfOne()
        if !children.isEmpty {
            object.children = children
        }
        
        return object
    }
    
    private func asArrayOfAnyRecursiveModelWithDepthOfOne() -> [AnyRecursiveModel<Element>] {
        let items = self
        
        guard let first = items.first else { return [] }
        
        var result: [AnyRecursiveModel<Element>] = []
        var remainingItems: [Element] = items
        
        var object = AnyRecursiveModel(value: first)
        
        remainingItems.remove(at: 0)
        let children = remainingItems.asArrayOfAnyRecursiveModelWithDepthOfOne()
        if !children.isEmpty {
            object.children = children
        }
        
        result.append(object)
        return result
    }

}




/*
 struct ModalSupportView: View {
     
     @State private var selection: AnyModalWithDestination? = nil

     let allowSimultaneous: Bool
     let transitions: [AnyModalWithDestination]
     
     var currentTransition: TransitionOption {
         transitions.last?.configuration.transition ?? .slide
     }
     
     var body: some View {
         ZStack {
             LazyZStack(allowSimultaneous: allowSimultaneous, selection: selection, items: transitions) { data in
                 LazyZStack(allowSimultaneous: true, selection: true) { showView1 in
                     if showView1 {
                         data.destination.destination
                             .id(data.id + currentTransition.rawValue)
                             .transition(
                                 .asymmetric(
                                     insertion: currentTransition.insertion,
                                     removal: currentTransition.removal
                                 )
                             )
                     } else {
                         if let backgroundColor = data.configuration.backgroundColor {
                             backgroundColor
                                 .frame(maxWidth: .infinity, maxHeight: .infinity)
                                 .edgesIgnoringSafeArea(.all)
                                 .transition(AnyTransition.opacity.animation(.easeInOut))
                             //                        .onTapGesture {
                             //                            item.wrappedValue = nil
                             //                        }
                         } else {
                             EmptyView()
                         }
                     }
                 }
             }
             .animation(.easeInOut, value: selection?.id)
         }
         .onFirstAppear {
             selection = transitions.last
         }
         .onChange(of: transitions, perform: { newValue in
             Task { @MainActor in
                 try? await Task.sleep(nanoseconds: 0)
                 selection = newValue.last
             }
         })
     }
 }
 */
