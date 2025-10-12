//
//  ModuleSupportView.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI
import SwiftfulRecursiveUI

struct ModuleSupportView<Content:View>: View {

    @StateObject private var viewModel = ModuleViewModel()

    var rootRouterInfo: (id: String, transitionBehavior: TransitionMemoryBehavior)?
    let addNavigationStack: Bool

    @ViewBuilder var content: (AnyRouter) -> Content

    @State private var viewFrame: CGRect = UIScreen.main.bounds

    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: viewModel.modules.last, items: viewModel.modules) { data in
                let dataIndex: Double = Double(viewModel.modules.firstIndex(where: { $0.id == data.id }) ?? 99)

                return Group {
                    if data == viewModel.modules.first {
                        RouterViewModelWrapper {
                            RouterViewInternal(
                                routerId: RouterViewModel.rootId,
                                rootRouterInfo: rootRouterInfo,
                                addNavigationStack: addNavigationStack,
                                content: content
                            )
                        }
                    } else {
                        RouterViewModelWrapper {
                            ModuleDestinationWrapper(
                                routerId: RouterViewModel.rootId,
                                rootRouterInfo: rootRouterInfo,
                                addNavigationStack: addNavigationStack,
                                destination: data.destination
                            )
                        }
                    }
                }
                .transition(
                    .asymmetric(
                        insertion: viewModel.currentTransition.insertion,
                        removal: .customRemoval(
                            behavior: .removePrevious,
                            direction: viewModel.currentTransition.reversed,
                            frame: viewFrame
                        )
                    )
                )
                .zIndex(dataIndex)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(viewModel.currentTransition.animation, value: (viewModel.modules.last?.id ?? "") + viewModel.currentTransition.rawValue)
        .environmentObject(viewModel)

        #if DEBUG
        .onChange(of: viewModel.modules) { newValue in
            viewModel.printModuleStack(modules: newValue)
        }
        #endif
    }
}

// Helper wrapper to properly handle toolbar modifiers in module destinations
// By wrapping in a separate View struct, we ensure the NavigationStack and toolbar
// have a stable view identity and can properly connect before the transition animation completes
private struct ModuleDestinationWrapper: View {
    let routerId: String
    let rootRouterInfo: (id: String, transitionBehavior: TransitionMemoryBehavior)?
    let addNavigationStack: Bool
    let destination: (AnyRouter) -> any View

    var body: some View {
        RouterViewInternal(
            routerId: routerId,
            rootRouterInfo: rootRouterInfo,
            addNavigationStack: addNavigationStack,
            content: { router in
                // Use a dedicated struct to perform type erasure
                // This maintains the view hierarchy better than direct AnyView in the closure
                ModuleDestinationContent(destination: destination(router))
            }
        )
    }
}

// Dedicated struct for rendering module destination content
// This provides a stable view identity that helps toolbar modifiers work correctly
private struct ModuleDestinationContent: View {
    let destination: any View

    var body: some View {
        AnyView(destination)
    }
}
