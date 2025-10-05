//
//  RouterViewInternal.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

@MainActor
struct RouterViewInternal<Content: View>: View, Router {

    @Environment(\.openURL) var openURL

    @EnvironmentObject var viewModel: RouterViewModel
    @EnvironmentObject var moduleViewModel: ModuleViewModel
    var routerId: String
    var rootRouterInfo: (id: String, transitionBehavior: TransitionMemoryBehavior)?
    var addNavigationStack: Bool = false
    var content: (AnyRouter) -> Content

    // Computed binding to viewModel's stable path (survives view recreation)
    private var stableNavigationPath: Binding<[AnyDestination]> {
        Binding(
            get: { viewModel.stableNavigationPaths[routerId] ?? [] },
            set: { viewModel.stableNavigationPaths[routerId] = $0 }
        )
    }

    private var currentRouter: AnyRouter {
        AnyRouter(id: routerId, rootRouterId: rootRouterInfo?.id ?? "", object: self)
    }
        
    var body: some View {
        // Wrap starting content for Transition support
        TransitionSupportView(
            behavior: parentDestination?.transitionBehavior ?? .keepPrevious,
            router: currentRouter,
            transitions: viewModel.allTransitions[routerId] ?? [],
            content: content,
            currentTransition: viewModel.currentTransitions[routerId] ?? .trailing,
            onDidSwipeBack: {
                dismissTransition()
            }
        )
        .id(routerId)
        .onFirstAppear {
            print("FIRST APPEAR ROUTER: \(routerId) - stablePath: \(viewModel.stableNavigationPaths[routerId]?.count ?? 0)")
        }
        .onAppear {
            print("APPEAR ROUTER: \(routerId) - stablePath: \(viewModel.stableNavigationPaths[routerId]?.count ?? 0)")
        }
        .onChange(of: routerId, perform: { newValue in
            print("CHANGE ROUTER: \(newValue)")
        })
        
        // Add NavigationStack if needed
        .ifSatisfiesCondition(addNavigationStack, transform: { content in
            let _ = print("NavigationStack for \(routerId) - path count: \(stableNavigationPath.wrappedValue.count)")
            return NavigationStack(path: stableNavigationPath) {
                content
                    .navigationDestination(for: AnyDestination.self) { value in
                        value.destination
                    }
                    .onChange(of: stableNavigationPath.wrappedValue, perform: { screenStack in
                        // User manually swiped back on screen
                        print("\(routerId) onChange(of: stableNavigationPath - \(screenStack.count)")
                        handleStableScreenStackDidChange(screenStack: screenStack)
                    })
                    .onChange(of: viewModel.activeScreenStacks) { newStack in
                        print("\(routerId) onChange(of: viewModel.activeScreenStacks - \(newStack.count)")
                        handleActiveScreenStackDidChange(newStack: newStack)
                    }
                
                    // There's a weird behavior (bug?) where the presentationDetent is not calculated
                    // If the .sheet modifier is outside of the NavigationStack
                    // Therefore, if we add NavigationStack, we add these as children of it
                    .sheetBackgroundModifier(viewModel: viewModel, routerId: routerId)
                    .fullScreenCoverBackgroundModifer(viewModel: viewModel, routerId: routerId)
            }
        })
        
        // If we don't add NavigationStack, add .sheet modifiers here instead
        .ifSatisfiesCondition(!addNavigationStack, transform: { content in
            content
                .sheetBackgroundModifier(viewModel: viewModel, routerId: routerId)
                .fullScreenCoverBackgroundModifer(viewModel: viewModel, routerId: routerId)
        })
        
        // If this is the root router, add "root" stack to the array
        .ifSatisfiesCondition(routerId == RouterViewModel.rootId, transform: { content in
            content
                .onFirstAppear {
                    let view = AnyDestination(
                        id: routerId,
                        segue: .fullScreenCover,
                        location: .insert,
                        animates: false,
                        transitionBehavior: rootRouterInfo?.transitionBehavior ?? .keepPrevious,
                        onDismiss: nil,
                        destination: { _ in self })
                    viewModel.insertRootView(rootRouterId: rootRouterInfo?.id, view: view)
                }
        })
        
        // Add Alert modifier.
        .modifier(AlertViewModifier(alert: Binding(get: {
            viewModel.activeAlert[routerId]
        }, set: { newValue in
            if newValue == nil {
                viewModel.dismissAlert(routerId: routerId)
            }
        })))
        
        // Add Modals modifier.
        .overlay(
            ModalSupportView(
                modals: viewModel.allModals[routerId] ?? [],
                onDismissModal: { modal in
                    viewModel.dismissModal(routerId: routerId, modalId: modal.id)
                }
            )
        )
        
        #if DEBUG
        // logging on every router
        .onChange(of: viewModel.allModals[routerId] ?? []) { newValue in
            viewModel.printModalStack(routerId: routerId, modals: newValue)
        }
        .onChange(of: viewModel.allTransitions[routerId] ?? []) { newValue in
            viewModel.printTransitionStack(routerId: routerId, transitions: newValue)
        }
        .onChange(of: viewModel.availableTransitionQueue[routerId] ?? []) { newValue in
            viewModel.printTransitionQueue(routerId: routerId, transitionQueue: newValue)
        }
        #endif
        
        // Add to environment for convenience
        .environment(\.router, currentRouter)
    }
    
    private var parentDestination: AnyDestination? {
        guard let index = viewModel.activeScreenStacks.lastIndex(where: { stack in
            return stack.screens.contains(where: { $0.id == routerId })
        }) else {
            return nil
        }
        
        return viewModel.activeScreenStacks[index].screens.first(where: { $0.id == routerId })
    }
    
    private func handleStableScreenStackDidChange(screenStack: [AnyDestination]) {
        let activeStack = viewModel.activeScreenStacks
        let index = activeStack.firstIndex { subStack in
            return subStack.screens.contains(where: { $0.id == routerId })
        }
        guard let index, activeStack.indices.contains(index + 1) else {
            return
        }

        if screenStack.count < activeStack[index + 1].screens.count {
            if let lastScreen = screenStack.last {
                viewModel.dismissScreens(to: lastScreen.id, animates: true)
            } else {
                viewModel.dismissPushStack(routeId: routerId, animates: true)
            }
        }
    }
    
    private func handleActiveScreenStackDidChange(newStack: [AnyDestinationStack]) {
        let index = newStack.firstIndex { subStack in
            return subStack.screens.contains(where: { $0.id == routerId })
        }
        guard let index, newStack.indices.contains(index + 1) else {
            print("handleActiveScreenStackDidChange - []")
            if viewModel.stableNavigationPaths[routerId] != [] {
                viewModel.stableNavigationPaths[routerId] = []
            }
            return
        }

        let activeStack = newStack[index + 1].screens
        print("handleActiveScreenStackDidChange - \(activeStack.count)")
        if viewModel.stableNavigationPaths[routerId] != activeStack {
            viewModel.stableNavigationPaths[routerId] = activeStack
        }
    }
            
    var activeScreens: [AnyDestinationStack] {
        viewModel.activeScreenStacks
    }
    
    var activeScreenQueue: [AnyDestination] {
        viewModel.availableScreenQueue
    }
    
    var activeAlert: AnyAlert? {
        viewModel.activeAlert[routerId]
    }
    
    var activeModals: [AnyModal] {
        viewModel.allModals[routerId]?.active ?? []
    }
    
    var activeTransitions: [AnyTransitionDestination] {
        viewModel.allTransitions[routerId] ?? []
    }
    
    var activeModules: [AnyTransitionDestination] {
        moduleViewModel.modules
    }
    
    var activeTransitionQueue: [AnyTransitionDestination] {
        viewModel.availableTransitionQueue[routerId] ?? []
    }
    
    func showScreens(destinations: [AnyDestination]) {
        viewModel.showScreens(routerId: routerId, destinations: destinations)
    }
    
    func showScreen(destination: AnyDestination) {
        viewModel.showScreens(routerId: routerId, destinations: [destination])
    }
    
    func dismissScreen(animates: Bool) {
        viewModel.dismissScreen(routeId: routerId, animates: animates)
    }
    
    func dismissScreen(id: String, animates: Bool) {
        viewModel.dismissScreen(routeId: id, animates: animates)
    }
    
    func dismissScreens(upToId: String, animates: Bool) {
        viewModel.dismissScreens(to: upToId, animates: animates)
    }
    
    func dismissScreens(count: Int, animates: Bool) {
        viewModel.dismissScreens(count: count, animates: animates)
    }
    
    func dismissLastScreen(animates: Bool) {
        viewModel.dismissLastScreen(animates: animates)
    }
    
    func dismissEnvironment(animates: Bool) {
        viewModel.dismissEnvironment(routeId: routerId, animates: animates)
    }
        
    func dismissLastEnvironment(animates: Bool) {
        viewModel.dismissLastEnvironment(animates: animates)
    }
    
    func dismissLastPushStack(animates: Bool) {
        viewModel.dismissLastPushStack(animates: animates)
    }
    
    func dismissPushStack(animates: Bool) {
        viewModel.dismissPushStack(routeId: routerId, animates: animates)
    }
    
    func dismissAllScreens(animates: Bool) {
        viewModel.dismissAllScreens(animates: animates)
    }
    
    func addScreensToQueue(destinations: [AnyDestination]) {
        viewModel.addScreensToQueue(routerId: routerId, destinations: destinations)
    }
    
    func removeScreensFromQueue(ids: [String]) {
        viewModel.removeScreensFromQueue(screenIds: ids)
    }
    
    func removeAllScreensFromQueue() {
        viewModel.removeAllScreensFromQueue()
    }
    
    func showNextScreen() {
        viewModel.showNextScreen(routerId: routerId)
    }
    
    func showAlert(alert: AnyAlert) {
        viewModel.showAlert(routerId: routerId, alert: alert)
    }
    
    func dismissAlert() {
        viewModel.dismissAlert(routerId: routerId)
    }
    
    func dismissAllAlerts() {
        viewModel.dismissAllAlerts()
    }
    
    func showModal(modal: AnyModal) {
        viewModel.showModal(routerId: routerId, modal: modal)
    }
    
    func dismissModal() {
        viewModel.dismissLastModal(onRouterId: routerId)
    }
    
    func dismissModal(id: String) {
        viewModel.dismissModal(routerId: routerId, modalId: id)
    }
    
    func dismissModals(upToId: String) {
        viewModel.dismissModals(routerId: routerId, to: upToId)
    }
    
    func dismissModals(count: Int) {
        viewModel.dismissModals(routerId: routerId, count: count)
    }
    
    func dismissAllModals() {
        viewModel.dismissAllModals(routerId: routerId)
    }
    
    func showTransition(transition: AnyTransitionDestination) {
        viewModel.showTransition(routerId: routerId, transition: transition)
    }
    
    func showTransitions(transitions: [AnyTransitionDestination]) {
        viewModel.showTransitions(routerId: routerId, transitions: transitions)
    }
    
    func dismissTransition() {
        viewModel.dismissTransition(routerId: routerId)
    }
    
    func dismissTransition(id: String) {
        viewModel.dismissTransitions(routerId: routerId, transitionId: id)
    }
    
    func dismissTransitions(upToId id: String) {
        viewModel.dismissTransitions(routerId: routerId, toTransitionId: id)
    }
    
    func dismissTransitions(count: Int) {
        viewModel.dismissTransitions(routerId: routerId, count: count)
    }
    
    func dismissAllTransitions() {
        viewModel.dismissAllTransitions(routerId: routerId)
    }
    
    func addTransitionsToQueue(transitions: [AnyTransitionDestination]) {
        viewModel.addTransitionsToQueue(routerId: routerId, transitions: transitions)
    }
    
    func removeTransitionsFromQueue(ids: [String]) {
        viewModel.removeTransitionsFromQueue(routerId: routerId, transitionIds: ids)
    }
    
    func removeAllTransitionsFromQueue() {
        viewModel.removeAllTransitionsFromQueue(routerId: routerId)
    }
    
    func showNextTransition() {
        viewModel.showNextTransition(routerId: routerId)
    }
    
    func showModule(module: AnyTransitionDestination) {
        moduleViewModel.showModule(module: module)
    }
    
    func showModules(modules: [AnyTransitionDestination]) {
        moduleViewModel.showModules(modules: modules)
    }
    
    func dismissModule() {
        moduleViewModel.dismissModule()
    }
    
    func dismissModule(id: String) {
        moduleViewModel.dismissModules(moduleId: id)
    }
    
    func dismissModules(upToId: String) {
        moduleViewModel.dismissModules(toModuleId: upToId)
    }
    
    func dismissModules(count: Int) {
        moduleViewModel.dismissModules(count: count)
    }
    
    func dismissAllModules() {
        moduleViewModel.dismissAllModules()
    }
    
    func showSafari(_ url: @escaping () -> URL) {
        let url = url()
        openURL(url)
        logger.trackEvent(event: RouterViewModel.Event.showSafari(url: url))
    }
}

extension View {
    
    func sheetBackgroundModifier(viewModel: RouterViewModel, routerId: String) -> some View {
        self
            .background(
                Text("")
                    .sheet(item: Binding(viewModel: viewModel, routerId: routerId, segue: .sheet, onDidDismiss: {
                        // This triggers if the user swipes down to dismiss the screen
                        // Now we must update activeScreenStacks to match that behavior
                        viewModel.dismissScreens(toEnvironmentId: routerId, animates: true)
                    }), onDismiss: nil) { destination in
                        destination.destination
                            .applyResizableSheetModifiersIfNeeded(segue: destination.segue)
                    }
            )
    }

    func fullScreenCoverBackgroundModifer(viewModel: RouterViewModel, routerId: String) -> some View {
        self
            .background(
                Text("")
                    .fullScreenCover(item: Binding(viewModel: viewModel, routerId: routerId, segue: .fullScreenCover, onDidDismiss: {
                        // This triggers if the user swipes down to dismiss the screen
                        // Now we must update activeScreenStacks to match that behavior
                        viewModel.dismissScreens(toEnvironmentId: routerId, animates: true)
                    }), onDismiss: nil) { destination in
                        destination.destination
                            .applyResizableSheetModifiersIfNeeded(segue: destination.segue)
                    }
            )
    }
}
