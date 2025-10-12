//
//  ModuleSupportView.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

struct ModuleSupportView<Content:View>: View {

    @StateObject private var viewModel = ModuleViewModel()

    var rootRouterInfo: (id: String, transitionBehavior: TransitionMemoryBehavior)?
    let addNavigationStack: Bool

    @ViewBuilder var content: (AnyRouter) -> Content

    @State private var viewFrame: CGRect = UIScreen.main.bounds

    var body: some View {
        ZStack {
            ForEach(viewModel.modules, id: \.id) { data in
                let dataIndex: Double = Double(viewModel.modules.firstIndex(where: { $0.id == data.id }) ?? 99)
                let isSelected = data.id == viewModel.modules.last?.id

                Group {
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
                            RouterViewInternal(
                                routerId: RouterViewModel.rootId,
                                rootRouterInfo: rootRouterInfo,
                                addNavigationStack: addNavigationStack,
                                content: { router in
                                    AnyView(data.destination(router))
                                }
                            )
                        }
                    }
                }
                .opacity(isSelected ? 1 : 0)
                .zIndex(isSelected ? dataIndex + 1 : dataIndex)
                .transition(
                    .asymmetric(
                        insertion: viewModel.currentTransition.insertion,
                        removal: viewModel.currentTransition.reversed.insertion
                    )
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(viewModel.currentTransition.animation, value: viewModel.modules.last?.id ?? "")
        .environmentObject(viewModel)

        #if DEBUG
        .onChange(of: viewModel.modules) { newValue in
            viewModel.printModuleStack(modules: newValue)
        }
        #endif
    }
}
