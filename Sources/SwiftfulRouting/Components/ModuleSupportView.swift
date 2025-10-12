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
                            _SimpleModuleView(
                                moduleId: data.id,
                                rootRouterInfo: rootRouterInfo,
                                addNavigationStack: addNavigationStack,
                                destination: data.destination
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

// Simplified module view that renders content directly in NavigationStack
// This avoids going through RouterViewInternal's generic Content parameter
private struct _SimpleModuleView: View {
    @EnvironmentObject var viewModel: RouterViewModel
    @EnvironmentObject var moduleViewModel: ModuleViewModel

    let moduleId: String
    let rootRouterInfo: (id: String, transitionBehavior: TransitionMemoryBehavior)?
    let addNavigationStack: Bool
    let destination: (AnyRouter) -> any View

    private var router: AnyRouter {
        AnyRouter(
            id: RouterViewModel.rootId,
            rootRouterId: rootRouterInfo?.id ?? "",
            object: _SimpleRouter(viewModel: viewModel, moduleViewModel: moduleViewModel)
        )
    }

    var body: some View {
        if addNavigationStack {
            NavigationStack {
                // Render destination content directly - toolbar is applied BEFORE type erasure
                _TypeErasedContent(content: destination(router))
                    .environment(\.router, router)
            }
        } else {
            // Render destination content directly - toolbar is applied BEFORE type erasure
            _TypeErasedContent(content: destination(router))
                .environment(\.router, router)
        }
    }
}

// Minimal type erasure wrapper
private struct _TypeErasedContent: View {
    let content: any View

    var body: some View {
        AnyView(content)
    }
}

// Minimal router implementation for modules
private struct _SimpleRouter: Router {
    let viewModel: RouterViewModel
    let moduleViewModel: ModuleViewModel

    var activeScreens: [AnyDestinationStack] { viewModel.activeScreenStacks }
    var activeScreenQueue: [AnyDestination] { viewModel.availableScreenQueue }
    var activeAlert: AnyAlert? { viewModel.activeAlert[RouterViewModel.rootId] }
    var activeModals: [AnyModal] { viewModel.allModals[RouterViewModel.rootId]?.active ?? [] }
    var activeTransitions: [AnyTransitionDestination] { viewModel.allTransitions[RouterViewModel.rootId] ?? [] }
    var activeModules: [AnyTransitionDestination] { moduleViewModel.modules }
    var activeTransitionQueue: [AnyTransitionDestination] { viewModel.availableTransitionQueue[RouterViewModel.rootId] ?? [] }

    func showScreens(destinations: [AnyDestination]) { viewModel.showScreens(routerId: RouterViewModel.rootId, destinations: destinations) }
    func dismissScreen(animates: Bool) { viewModel.dismissScreen(routeId: RouterViewModel.rootId, animates: animates) }
    func dismissScreen(id: String, animates: Bool) { viewModel.dismissScreen(routeId: id, animates: animates) }
    func dismissScreens(upToId: String, animates: Bool) { viewModel.dismissScreens(to: upToId, animates: animates) }
    func dismissScreens(count: Int, animates: Bool) { viewModel.dismissScreens(count: count, animates: animates) }
    func dismissPushStack(animates: Bool) { viewModel.dismissPushStack(routeId: RouterViewModel.rootId, animates: animates) }
    func dismissEnvironment(animates: Bool) { viewModel.dismissEnvironment(routeId: RouterViewModel.rootId, animates: animates) }
    func dismissLastScreen(animates: Bool) { viewModel.dismissLastScreen(animates: animates) }
    func dismissLastPushStack(animates: Bool) { viewModel.dismissLastPushStack(animates: animates) }
    func dismissLastEnvironment(animates: Bool) { viewModel.dismissLastEnvironment(animates: animates) }
    func dismissAllScreens(animates: Bool) { viewModel.dismissAllScreens(animates: animates) }
    func addScreensToQueue(destinations: [AnyDestination]) { viewModel.addScreensToQueue(routerId: RouterViewModel.rootId, destinations: destinations) }
    func removeScreensFromQueue(ids: [String]) { viewModel.removeScreensFromQueue(screenIds: ids) }
    func removeAllScreensFromQueue() { viewModel.removeAllScreensFromQueue() }
    func showNextScreen() { viewModel.showNextScreen(routerId: RouterViewModel.rootId) }
    func showAlert(alert: AnyAlert) { viewModel.showAlert(routerId: RouterViewModel.rootId, alert: alert) }
    func dismissAlert() { viewModel.dismissAlert(routerId: RouterViewModel.rootId) }
    func dismissAllAlerts() { viewModel.dismissAllAlerts() }
    func showModal(modal: AnyModal) { viewModel.showModal(routerId: RouterViewModel.rootId, modal: modal) }
    func dismissModal() { viewModel.dismissLastModal(onRouterId: RouterViewModel.rootId) }
    func dismissModal(id: String) { viewModel.dismissModal(routerId: RouterViewModel.rootId, modalId: id) }
    func dismissModals(upToId: String) { viewModel.dismissModals(routerId: RouterViewModel.rootId, to: upToId) }
    func dismissModals(count: Int) { viewModel.dismissModals(routerId: RouterViewModel.rootId, count: count) }
    func dismissAllModals() { viewModel.dismissAllModals(routerId: RouterViewModel.rootId) }
    func showTransition(transition: AnyTransitionDestination) { viewModel.showTransition(routerId: RouterViewModel.rootId, transition: transition) }
    func showTransitions(transitions: [AnyTransitionDestination]) { viewModel.showTransitions(routerId: RouterViewModel.rootId, transitions: transitions) }
    func dismissTransition() { viewModel.dismissTransition(routerId: RouterViewModel.rootId) }
    func dismissTransition(id: String) { viewModel.dismissTransitions(routerId: RouterViewModel.rootId, transitionId: id) }
    func dismissTransitions(upToId: String) { viewModel.dismissTransitions(routerId: RouterViewModel.rootId, toTransitionId: upToId) }
    func dismissTransitions(count: Int) { viewModel.dismissTransitions(routerId: RouterViewModel.rootId, count: count) }
    func dismissAllTransitions() { viewModel.dismissAllTransitions(routerId: RouterViewModel.rootId) }
    func addTransitionsToQueue(transitions: [AnyTransitionDestination]) { viewModel.addTransitionsToQueue(routerId: RouterViewModel.rootId, transitions: transitions) }
    func removeTransitionsFromQueue(ids: [String]) { viewModel.removeTransitionsFromQueue(routerId: RouterViewModel.rootId, transitionIds: ids) }
    func removeAllTransitionsFromQueue() { viewModel.removeAllTransitionsFromQueue(routerId: RouterViewModel.rootId) }
    func showNextTransition() { viewModel.showNextTransition(routerId: RouterViewModel.rootId) }
    func showModule(module: AnyTransitionDestination) { moduleViewModel.showModule(module: module) }
    func showModules(modules: [AnyTransitionDestination]) { moduleViewModel.showModules(modules: modules) }
    func dismissModule() { moduleViewModel.dismissModule() }
    func dismissModule(id: String) { moduleViewModel.dismissModules(moduleId: id) }
    func dismissModules(upToId: String) { moduleViewModel.dismissModules(toModuleId: upToId) }
    func dismissModules(count: Int) { moduleViewModel.dismissModules(count: count) }
    func dismissAllModules() { moduleViewModel.dismissAllModules() }
    func showSafari(_ url: @escaping () -> URL) { /* Not implemented for modules */ }
}
