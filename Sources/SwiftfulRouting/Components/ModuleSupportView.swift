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
                                routerId: data.id,  // Use module's unique ID
                                rootRouterInfo: rootRouterInfo,
                                addNavigationStack: addNavigationStack,
                                content: content
                            )
                        }
                    } else {
                        RouterViewModelWrapper {
                            RouterViewInternal(
                                routerId: data.id,  // Use module's unique ID
                                rootRouterInfo: rootRouterInfo,
                                addNavigationStack: addNavigationStack,
                                content: { router in
                                    // Cast to AnyView to allow type erasure while maintaining view identity
                                    AnyView(data.destination(router))
                                }
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
