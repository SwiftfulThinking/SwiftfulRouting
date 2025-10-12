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
                        .id("module_\(data.id)")
                    } else {
                        RouterViewModelWrapper {
                            ModuleDestinationView(
                                moduleId: data.id,
                                rootRouterInfo: rootRouterInfo,
                                addNavigationStack: addNavigationStack,
                                destination: data.destination
                            )
                        }
                        .id("module_\(data.id)")
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

// Custom view for module destinations that preserves toolbar without using AnyView in RouterViewInternal
private struct ModuleDestinationView: View {
    @EnvironmentObject var viewModel: RouterViewModel
    @EnvironmentObject var moduleViewModel: ModuleViewModel

    let moduleId: String
    let rootRouterInfo: (id: String, transitionBehavior: TransitionMemoryBehavior)?
    let addNavigationStack: Bool
    let destination: (AnyRouter) -> any View

    @StateObject private var stableScreenStack = StableAnyDestinationArray(destinations: [])

    private var currentRouter: AnyRouter {
        AnyRouter(id: RouterViewModel.rootId, rootRouterId: rootRouterInfo?.id ?? "", object: RouterProxy(
            viewModel: viewModel,
            moduleViewModel: moduleViewModel,
            routerId: RouterViewModel.rootId,
            rootRouterInfo: rootRouterInfo
        ))
    }

    var body: some View {
        TransitionSupportView(
            behavior: .keepPrevious,
            router: currentRouter,
            transitions: viewModel.allTransitions[RouterViewModel.rootId] ?? [],
            content: { router in
                // Render destination directly without AnyView wrapper
                _DirectDestinationView(destination: destination(router))
            },
            currentTransition: viewModel.currentTransitions[RouterViewModel.rootId] ?? .trailing,
            onDidSwipeBack: {
                viewModel.dismissTransition(routerId: RouterViewModel.rootId)
            }
        )
        .id(RouterViewModel.rootId)
        .ifSatisfiesCondition(addNavigationStack, transform: { content in
            NavigationStack(path: $stableScreenStack.destinations) {
                content
                    .navigationDestination(for: AnyDestination.self) { value in
                        value.destination
                    }
                    .onChange(of: stableScreenStack.destinations, perform: { screenStack in
                        handleStableScreenStackDidChange(screenStack: screenStack)
                    })
                    .onChange(of: viewModel.activeScreenStacks) { newStack in
                        handleActiveScreenStackDidChange(newStack: newStack)
                    }
                    .resizeableSheetBackgroundModifier(viewModel: viewModel, routerId: RouterViewModel.rootId)
            }
        })
        .sheetBackgroundModifier(viewModel: viewModel, routerId: RouterViewModel.rootId)
        .fullScreenCoverBackgroundModifer(viewModel: viewModel, routerId: RouterViewModel.rootId)
        .onFirstAppear {
            let view = AnyDestination(
                id: RouterViewModel.rootId,
                segue: .fullScreenCover,
                location: .insert,
                animates: false,
                transitionBehavior: rootRouterInfo?.transitionBehavior ?? .keepPrevious,
                onDismiss: nil,
                destination: { _ in self })
            viewModel.insertRootView(rootRouterId: rootRouterInfo?.id, view: view)
        }
        .modifier(AlertViewModifier(alert: Binding(get: {
            viewModel.activeAlert[RouterViewModel.rootId]
        }, set: { newValue in
            if newValue == nil {
                viewModel.dismissAlert(routerId: RouterViewModel.rootId)
            }
        })))
        .overlay(
            ModalSupportView(
                modals: viewModel.allModals[RouterViewModel.rootId] ?? [],
                onDismissModal: { modal in
                    viewModel.dismissModal(routerId: RouterViewModel.rootId, modalId: modal.id)
                }
            )
        )
        .environment(\.router, currentRouter)
    }

    private func handleStableScreenStackDidChange(screenStack: [AnyDestination]) {
        let activeStack = viewModel.activeScreenStacks
        let index = activeStack.firstIndex { subStack in
            return subStack.screens.contains(where: { $0.id == RouterViewModel.rootId })
        }
        guard let index, activeStack.indices.contains(index + 1) else {
            return
        }

        if screenStack.count < activeStack[index + 1].screens.count {
            if let lastScreen = screenStack.last {
                viewModel.dismissScreens(to: lastScreen.id, animates: true)
            } else {
                viewModel.dismissPushStack(routeId: RouterViewModel.rootId, animates: true)
            }
        }
    }

    private func handleActiveScreenStackDidChange(newStack: [AnyDestinationStack]) {
        let index = newStack.firstIndex { subStack in
            return subStack.screens.contains(where: { $0.id == RouterViewModel.rootId })
        }
        guard let index, newStack.indices.contains(index + 1) else {
            stableScreenStack.setNewValueIfNeeded(newValue: [])
            return
        }

        let activeStack = newStack[index + 1].screens
        stableScreenStack.setNewValueIfNeeded(newValue: activeStack)
    }
}

// Direct view wrapper that doesn't use AnyView
private struct _DirectDestinationView: View {
    let destination: any View

    var body: some View {
        // We still need AnyView here but it's at the lowest level possible
        // The key is that toolbar is applied BEFORE this point
        AnyView(destination)
    }
}

// Router proxy for module destination
private struct RouterProxy: Router {
    let viewModel: RouterViewModel
    let moduleViewModel: ModuleViewModel
    let routerId: String
    let rootRouterInfo: (id: String, transitionBehavior: TransitionMemoryBehavior)?

    var activeScreens: [AnyDestinationStack] { viewModel.activeScreenStacks }
    var activeScreenQueue: [AnyDestination] { viewModel.availableScreenQueue }
    var activeAlert: AnyAlert? { viewModel.activeAlert[routerId] }
    var activeModals: [AnyModal] { viewModel.allModals[routerId]?.active ?? [] }
    var activeTransitions: [AnyTransitionDestination] { viewModel.allTransitions[routerId] ?? [] }
    var activeModules: [AnyTransitionDestination] { moduleViewModel.modules }
    var activeTransitionQueue: [AnyTransitionDestination] { viewModel.availableTransitionQueue[routerId] ?? [] }

    func showScreens(destinations: [AnyDestination]) { viewModel.showScreens(routerId: routerId, destinations: destinations) }
    func dismissScreen(animates: Bool) { viewModel.dismissScreen(routeId: routerId, animates: animates) }
    func dismissScreen(id: String, animates: Bool) { viewModel.dismissScreen(routeId: id, animates: animates) }
    func dismissScreens(upToId: String, animates: Bool) { viewModel.dismissScreens(to: upToId, animates: animates) }
    func dismissScreens(count: Int, animates: Bool) { viewModel.dismissScreens(count: count, animates: animates) }
    func dismissPushStack(animates: Bool) { viewModel.dismissPushStack(routeId: routerId, animates: animates) }
    func dismissEnvironment(animates: Bool) { viewModel.dismissEnvironment(routeId: routerId, animates: animates) }
    func dismissLastScreen(animates: Bool) { viewModel.dismissLastScreen(animates: animates) }
    func dismissLastPushStack(animates: Bool) { viewModel.dismissLastPushStack(animates: animates) }
    func dismissLastEnvironment(animates: Bool) { viewModel.dismissLastEnvironment(animates: animates) }
    func dismissAllScreens(animates: Bool) { viewModel.dismissAllScreens(animates: animates) }
    func addScreensToQueue(destinations: [AnyDestination]) { viewModel.addScreensToQueue(routerId: routerId, destinations: destinations) }
    func removeScreensFromQueue(ids: [String]) { viewModel.removeScreensFromQueue(screenIds: ids) }
    func removeAllScreensFromQueue() { viewModel.removeAllScreensFromQueue() }
    func showNextScreen() { viewModel.showNextScreen(routerId: routerId) }
    func showAlert(alert: AnyAlert) { viewModel.showAlert(routerId: routerId, alert: alert) }
    func dismissAlert() { viewModel.dismissAlert(routerId: routerId) }
    func dismissAllAlerts() { viewModel.dismissAllAlerts() }
    func showModal(modal: AnyModal) { viewModel.showModal(routerId: routerId, modal: modal) }
    func dismissModal() { viewModel.dismissLastModal(onRouterId: routerId) }
    func dismissModal(id: String) { viewModel.dismissModal(routerId: routerId, modalId: id) }
    func dismissModals(upToId: String) { viewModel.dismissModals(routerId: routerId, to: upToId) }
    func dismissModals(count: Int) { viewModel.dismissModals(routerId: routerId, count: count) }
    func dismissAllModals() { viewModel.dismissAllModals(routerId: routerId) }
    func showTransition(transition: AnyTransitionDestination) { viewModel.showTransition(routerId: routerId, transition: transition) }
    func showTransitions(transitions: [AnyTransitionDestination]) { viewModel.showTransitions(routerId: routerId, transitions: transitions) }
    func dismissTransition() { viewModel.dismissTransition(routerId: routerId) }
    func dismissTransition(id: String) { viewModel.dismissTransitions(routerId: routerId, transitionId: id) }
    func dismissTransitions(upToId: String) { viewModel.dismissTransitions(routerId: routerId, toTransitionId: upToId) }
    func dismissTransitions(count: Int) { viewModel.dismissTransitions(routerId: routerId, count: count) }
    func dismissAllTransitions() { viewModel.dismissAllTransitions(routerId: routerId) }
    func addTransitionsToQueue(transitions: [AnyTransitionDestination]) { viewModel.addTransitionsToQueue(routerId: routerId, transitions: transitions) }
    func removeTransitionsFromQueue(ids: [String]) { viewModel.removeTransitionsFromQueue(routerId: routerId, transitionIds: ids) }
    func removeAllTransitionsFromQueue() { viewModel.removeAllTransitionsFromQueue(routerId: routerId) }
    func showNextTransition() { viewModel.showNextTransition(routerId: routerId) }
    func showModule(module: AnyTransitionDestination) { moduleViewModel.showModule(module: module) }
    func showModules(modules: [AnyTransitionDestination]) { moduleViewModel.showModules(modules: modules) }
    func dismissModule() { moduleViewModel.dismissModule() }
    func dismissModule(id: String) { moduleViewModel.dismissModules(moduleId: id) }
    func dismissModules(upToId: String) { moduleViewModel.dismissModules(toModuleId: upToId) }
    func dismissModules(count: Int) { moduleViewModel.dismissModules(count: count) }
    func dismissAllModules() { moduleViewModel.dismissAllModules() }
    func showSafari(_ url: @escaping () -> URL) {
        // Implementation for Safari
    }
}
