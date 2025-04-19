//
//  RouterView.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

/// A SwiftUI view that injects a router system into the environment, enabling navigation and routing for all child views.
/// Use this in place of a `NavigationStack` as the root of your view hierarchy.
///
/// Example usage:
/// ```swift
/// RouterView { router in
///     MyView(router: router)
/// }
///
/// ```
/// The returned router is also added to the child Environment, so you don't have to pass it manually:
/// ```swift
/// RouterView { _ in
///     MyView()
/// }
/// ```
///
/// - Parameters:
///   - id: Identifier for analytics for the first screen.
///   - addNavigationStack: Whether to wrap the root content in a `NavigationStack`. Defaults to `true`.
///   - addModuleSupport: Enables showModule methods for this view heirarchy.
///   - content: A closure that provides the root content view, receiving an `AnyRouter` instance for navigation control.
struct RouterView<Content: View>: View {
    
    var id: String = RouterViewModel.rootId
    var addNavigationStack: Bool = true
    var addModuleSupport: Bool = false
    @ViewBuilder var content: (AnyRouter) -> Content

    var body: some View {
        Group {
            if addModuleSupport {
                ModuleSupportView(
                    rootRouterId: id,
                    addNavigationStack: addNavigationStack,
                    content: content
                )
            } else {
                RouterViewModelWrapper {
                    RouterViewInternal(
                        routerId: RouterViewModel.rootId,
                        rootRouterId: id,
                        addNavigationStack: addNavigationStack,
                        content: content
                    )
                }
            }
        }
    }
}

struct RouterViewModelWrapper<Content: View>: View {
    
    @StateObject private var viewModel = RouterViewModel()
    @ViewBuilder var content: Content

    var body: some View {
        content
            .environmentObject(viewModel)

            #if DEBUG
            .onChange(of: viewModel.activeScreenStacks) { newValue in
                viewModel.printScreenStack(screenStack: newValue)
            }
            .onChange(of: viewModel.availableScreenQueue) { newValue in
                viewModel.printScreenQueue(screenQueue: newValue)
            }
            #endif
    }
}
