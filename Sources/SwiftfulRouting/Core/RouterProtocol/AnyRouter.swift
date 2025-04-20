//
//  AnyRouter.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

/// Type-erased Router with convenience methods.
public struct AnyRouter: Sendable, Router {
    private let object: any Router

    init(object: any Router) {
        self.object = object
    }
    
    /// Active screen stacks in this RouterView's heirarchy.
    ///
    /// Use activeScreens.allScreens for underlying screen array.
    @MainActor public var activeScreens: [AnyDestinationStack] {
        object.activeScreens
    }
    
    /// Available screens in this RouterView's screen queue.
    ///
    /// Use showNextScreen() to trigger the next screen.
    @MainActor public var activeScreenQueue: [AnyDestination] {
        object.activeScreenQueue
    }
    
    /// If there is at least 1 screen in activeScreenQueue.
    @MainActor public var hasScreenInQueue: Bool {
        !object.activeScreenQueue.isEmpty
    }
    
    /// The currently displayed alert on this screen.
    @MainActor public var activeAlert: AnyAlert? {
        object.activeAlert
    }
    
    /// If an alert is currently displayed on this screen.
    @MainActor public var hasActiveAlert: Bool {
        activeAlert != nil
    }
    
    /// Active modals displayed on this screen.
    @MainActor public var activeModals: [AnyModal] {
        object.activeModals
    }
    
    /// If a modal is currently displayed on this screen.
    @MainActor public var hasActiveModal: Bool {
        !object.activeModals.isEmpty
    }
    
    /// Active transition heirarchy on this screen.
    @MainActor public var activeTransitions: [AnyTransitionDestination] {
        object.activeTransitions
    }
    
    /// If there is an active transition on this screen.
    @MainActor public var hasActiveTransition: Bool {
        !object.activeTransitions.isEmpty
    }
    
    /// Available transition destinations in this screen's tranisition queue.
    ///
    /// Use showNextTransition() to trigger the next transition.
    @MainActor public var activeTransitionQueue: [AnyTransitionDestination] {
        object.activeTransitionQueue
    }
    
    /// If there is at least 1 transition in activeTransitionQueue.
    @MainActor public var hasTransitionInQueue: Bool {
        !object.activeTransitionQueue.isEmpty
    }
    
    /// Active transition heirarchy on this screen.
    @MainActor public var activeModules: [AnyTransitionDestination] {
        object.activeModules
    }
    
    /// Segue to a new screen.
    /// - Parameters:
    ///   - segue: Push (NavigationLink), Sheet, or FullScreenCover
    ///   - id: Identifier for the screen
    ///   - location: Where to insert the new screen in the heirarchy (default = .insert)
    ///   - onDismiss: Trigger closure when screen gets dismissed (note: dismiss != disappear)
    ///   - animates: If the segue should animate or not (default = true)
    ///   - transitionBehavior: Determines the behavior of "transition" methods on the destination screen.
    ///   - destination: The destination screen.
    @MainActor public func showScreen<T>(
        _ segue: SegueOption = .push,
        id: String = UUID().uuidString,
        location: SegueLocation = .insert,
        animates: Bool = true,
        transitionBehavior: TransitionMemoryBehavior = .keepPrevious,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let destination = AnyDestination(id: id, segue: segue, location: location, animates: animates, transitionBehavior: transitionBehavior, onDismiss: onDismiss, destination: destination)
        object.showScreens(destinations: [destination])
    }

    /// Add one screen to the screen heirarchy.
    @MainActor public func showScreen(destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    /// Add one screen to the screen heirarchy.
    @MainActor public func showScreen(_ destination: AnyDestination) {
        object.showScreens(destinations: [destination])
    }
    
    /// Add multiple screens to the screen heirarchy. Immediately trigger screens in order, resulting with the last screen displayed to the user.
    ///
    /// Note: destination.location will be overridden to support this method.
    @MainActor public func showScreens(destinations: [AnyDestination]) {
        object.showScreens(destinations: destinations)
    }
        
    /// Dismiss this screen and all screens in front of it.
    @MainActor public func dismissScreen(animates: Bool = true) {
        object.dismissScreen(animates: animates)
    }
    
    /// Dismiss screens after and including screen at id.
    @MainActor public func dismissScreen(id: String, animates: Bool = true) {
        object.dismissScreen(id: id, animates: animates)
    }
    
    /// Dismiss all screens in front of (but not including) screen at id.
    @MainActor public func dismissScreens(upToId: String, animates: Bool = true) {
        object.dismissScreens(upToId: upToId, animates: animates)
    }
    
    /// Dismiss a specific number of screens.
    @MainActor public func dismissScreens(count: Int, animates: Bool = true) {
        object.dismissScreens(count: count, animates: animates)
    }
    
    /// Dismiss all .push segues on the NavigationStack for this screen.
    @MainActor public func dismissPushStack(animates: Bool = true) {
        object.dismissPushStack(animates: animates)
    }
    
    /// Dismiss the closest .sheet or .fullScreenCover to this screen.
    @MainActor public func dismissEnvironment(animates: Bool = true) {
        object.dismissEnvironment(animates: animates)
    }
    
    /// Dismiss the last screen in the heirarchy, regardless of call-site.
    @MainActor public func dismissLastScreen(animates: Bool = true) {
        object.dismissLastScreen(animates: animates)
    }
    
    /// Dismiss all .push segues on the last NavigationStack in the heirarchy, regardless of call-site.
    @MainActor public func dismissLastPushStack(animates: Bool = true) {
        object.dismissLastPushStack(animates: animates)
    }
    
    /// Dismiss the last .sheet or .fullScreenCover in the heirarchy, regardless of call-site.
    @MainActor public func dismissLastEnvironment(animates: Bool = true) {
        object.dismissLastEnvironment(animates: animates)
    }
    
    /// Dismiss all screens in the heirarchy.
    @MainActor public func dismissAllScreens(animates: Bool = true) {
        object.dismissAllScreens(animates: animates)
    }
    
    /// Add 1 screen to this RouterView's screen queue.
    ///
    /// Use showNextScreen() to trigger the next screen.
    @MainActor public func addScreenToQueue(destination: AnyDestination) {
        object.addScreensToQueue(destinations: [destination])
    }
    
    /// Add multiple screens to this RouterView's screen queue.
    ///
    /// Use showNextScreen() to trigger the next screen.
    @MainActor public func addScreensToQueue(destinations: [AnyDestination]) {
        object.addScreensToQueue(destinations: destinations)
    }
    
    /// Remove 1 screen from this RouterView's screen queue.
    @MainActor public func removeScreenFromQueue(id: String) {
        object.removeScreensFromQueue(ids: [id])
    }
    
    /// Remove multiple screens from this RouterView's screen queue.
    @MainActor public func removeScreensFromQueue(ids: [String]) {
        object.removeScreensFromQueue(ids: ids)
    }
    
    /// Remove all screens from this RouterView's screen queue.
    @MainActor public func removeAllScreensFromQueue() {
        object.removeAllScreensFromQueue()
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available.
    @MainActor public func showNextScreen() {
        object.showNextScreen()
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, otherwise throw an error.
    @MainActor public func tryShowNextScreen() throws {
        guard hasScreenInQueue else {
            throw AnyRouterError.noScreensInQueue
        }
        
        object.showNextScreen()
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available, otherwise dismiss the screen.
    @MainActor public func showNextScreenOrDismissScreen(animateDismiss: Bool = true) {
        do {
            try tryShowNextScreen()
        } catch {
            object.dismissScreen(animates: animateDismiss)
        }
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available, otherwise dismiss the environment.
    @MainActor public func showNextScreenOrDismissEnvironment(animateDismiss: Bool = true) throws {
        do {
            try tryShowNextScreen()
        } catch {
            object.dismissEnvironment(animates: animateDismiss)
        }
    }
    
    /// Segue to a the first screen in this RouterView's screen queue, if available, otherwise dismiss the .push stack.
    @MainActor public func showNextScreenOrDismissPushStack(animateDismiss: Bool = true) throws {
        do {
            try tryShowNextScreen()
        } catch {
            object.dismissPushStack(animates: animateDismiss)
        }
    }
    
    
    // MARK: ALERTS
    
    
    /// Display an alert.
    /// - Parameters:
    ///   - style: Type of alert.
    ///   - location: Which screen to display alert on.
    ///   - title: Title of alert.
    ///   - subtitle: Subtitle of alert (optional)
    ///   - buttons: Buttons within alert (hint: use Group with multiple Button inside).
    @MainActor public func showAlert<T:View>(
        _ style: AlertStyle = .alert,
        location: AlertLocation = .topScreen,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder buttons: @escaping () -> T
    ) where T : View {
        let alert = AnyAlert(style: style, location: location, title: title, subtitle: subtitle, buttons: buttons)
        object.showAlert(alert: alert)
    }
    
    /// Display an alert with "OK" button.
    /// - Parameters:
    ///   - style: Type of alert.
    ///   - location: Which screen to display alert on.
    ///   - title: Title of alert.
    ///   - subtitle: Subtitle of alert (optional)
    @MainActor public func showAlert(
        _ style: AlertStyle = .alert,
        location: AlertLocation = .topScreen,
        title: String,
        subtitle: String? = nil
    ) {
        let alert = AnyAlert(style: style, location: location, title: title, subtitle: subtitle)
        object.showAlert(alert: alert)
    }
    
    /// Display an alert.
    @MainActor public func showAlert(alert: AnyAlert) {
        object.showAlert(alert: alert)
    }
    
    /// Display an alert.
    @MainActor public func showAlert(_ alert: AnyAlert) {
        object.showAlert(alert: alert)
    }
    
    /// Display a simple alert with title and "OK" button.
    @MainActor public func showBasicAlert(text: String, action: (() -> Void)? = nil) {
        showAlert(.alert, title: text) {
            Button("OK") {
                action?()
            }
        }
    }
    
    /// Dismiss alert displayed on this screen.
    @MainActor public func dismissAlert() {
        object.dismissAlert()
    }
    
    /// Dismiss all alert displayed on all screens.
    @MainActor public func dismissAllAlerts() {
        object.dismissAllAlerts()
    }

    // MARK: MODALS
    
    
    /// Show a modal.
    /// - Parameters:
    ///   - id: Identifier for modal.
    ///   - transition: Transition to show and hide modal.
    ///   - animation: Animation to show and hide modal.
    ///   - alignment: Alignment within the screen.
    ///   - backgroundColor: Background color behind the modal, if applicable.
    ///   - backgroundEffect: Background effect behind the modal, if applicable.
    ///   - dismissOnBackgroundTap: If there is a background color/effect, add tap gesture that dismisses the modal.
    ///   - ignoreSafeArea: Ignore screen's safe area when displayed.
    ///   - onDismiss: Closure that triggers when modal dismisses.
    ///   - destination: The modal View.
    @MainActor public func showModal<T>(
        id: String = UUID().uuidString,
        transition: AnyTransition = .identity,
        animation: Animation = .smooth,
        alignment: Alignment = .center,
        backgroundColor: Color? = nil,
        backgroundEffect: BackgroundEffect? = nil,
        dismissOnBackgroundTap: Bool = true,
        ignoreSafeArea: Bool = true,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder destination: @escaping () -> T
    ) where T : View {
            let modal = AnyModal(
                id: id,
                transition: transition,
                animation: animation,
                alignment: alignment,
                backgroundColor: backgroundColor,
                backgroundEffect: backgroundEffect,
                dismissOnBackgroundTap: dismissOnBackgroundTap,
                ignoreSafeArea: ignoreSafeArea,
                destination: destination,
                onDismiss: onDismiss
            )
            object.showModal(modal: modal)
    }
    
    /// Convenience method to show a modal with basic animation and display logic.
    @MainActor public func showBasicModal<T>(@ViewBuilder destination: @escaping () -> T) where T : View {
        showModal(
            transition: AnyTransition.opacity.animation(.easeInOut),
            animation: .easeInOut,
            alignment: .center,
            backgroundColor: Color.black.opacity(0.3),
            dismissOnBackgroundTap: true,
            ignoreSafeArea: true,
            destination: destination
        )
    }
    
    /// Convenience method to show a modal with basic animation and display logic.
    @MainActor public func showBottomModal<T>(@ViewBuilder destination: @escaping () -> T) where T : View {
        showModal(
            transition: AnyTransition.move(edge: .bottom),
            animation: .easeInOut,
            alignment: .bottom,
            backgroundColor: Color.black.opacity(0.3),
            dismissOnBackgroundTap: true,
            ignoreSafeArea: true,
            destination: destination
        )
    }
    
    /// Show a modal.
    @MainActor public func showModal(modal: AnyModal) {
        object.showModal(modal: modal)
    }
    
    /// Show a modal.
    @MainActor public func showModal(_ modal: AnyModal) {
        object.showModal(modal: modal)
    }
    
    /// Show multiple modals.
    @MainActor public func showModals(modals: [AnyModal]) {
        for modal in modals {
            object.showModal(modal: modal)
        }
    }
    
    /// Dismiss the last modal displayed on this screen.
    @MainActor public func dismissModal() {
        object.dismissModal()
    }
    
    /// Dismiss the modal at id on this screen.
    @MainActor public func dismissModal(id: String) {
        object.dismissModal(id: id)
    }
    
    /// Dismiss all modals in front of, but not including, modal id on this screen.
    @MainActor public func dismissModals(upToId: String) {
        object.dismissModals(upToId: upToId)
    }
    
    /// Dismiss specific number modals on this screen.
    @MainActor public func dismissModals(count: Int) {
        object.dismissModals(count: count)
    }
    
    /// Dismiss all modals on this screen.
    @MainActor public func dismissAllModals() {
        object.dismissAllModals()
    }
    
    /// Transition current screen.
    /// - Parameters:
    ///   - transition: Transition animation option.
    ///   - id: Identifier for transition id.
    ///   - allowsSwipeBack: Add a swipe-back gesture to the edge of the screen. Note: only works with .trailing or .leading transitions.
    ///   - onDismiss: Closure that triggers when transition is dismissed.
    ///   - destination: Destination screen.
    @MainActor public func showTransition<T>(
        _ transition: TransitionOption = .trailing,
        id: String = UUID().uuidString,
        allowsSwipeBack: Bool = false,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let transition = AnyTransitionDestination(id: id, transition: transition, allowsSwipeBack: allowsSwipeBack, destination: destination)
        object.showTransition(transition: transition)
    }
    
    /// Transition current screen.
    @MainActor public func showTransition(transition: AnyTransitionDestination) {
        object.showTransition(transition: transition)
    }
    
    /// Transition current screen.
    @MainActor public func showTransition(_ transition: AnyTransitionDestination) {
        object.showTransition(transition: transition)
    }
    
    /// Transition current screen, adding multiple transitions to heirarchy, and displaying the last one.
    @MainActor public func showTransitions(transitions: [AnyTransitionDestination]) {
        object.showTransitions(transitions: transitions)
    }
    
    /// Dismiss the last transition on this screen.
    @MainActor public func dismissTransition() {
        object.dismissTransition()
    }
    
    /// Dismiss all transitions after and including id on this screen.
    @MainActor public func dismissTransition(id: String) {
        object.dismissTransition(id: id)
    }
    
    /// Dismiss all transitions after, but not including id, on this screen.
    @MainActor public func dismissTransitions(upToId: String) {
        object.dismissTransitions(upToId: upToId)
    }
    
    /// Dismiss specific number of transitions on this screen.
    @MainActor public func dismissTransitions(count: Int) {
        object.dismissTransitions(count: count)
    }
    
    /// Dismiss transition, if available, or dismiss screen.
    @MainActor public func dismissTransitionOrDismissScreen() {
        if hasActiveTransition {
            dismissTransition()
        } else {
            dismissScreen()
        }
    }
    
    /// Dismiss all transitions on this screen.
    @MainActor public func dismissAllTransitions() {
        object.dismissAllTransitions()
    }

    /// Add 1 transition to this RouterView's transition queue.
    ///
    /// Use showNextTransition() to trigger the next transition.
    @MainActor public func addTransitionToQueue(transition: AnyTransitionDestination) {
        object.addTransitionsToQueue(transitions: [transition])
    }
    
    /// Add multiple transitions to this RouterView's transition queue.
    ///
    /// Use showNextTransition() to trigger the next transition.
    @MainActor public func addTransitionsToQueue(transitions: [AnyTransitionDestination]) {
        object.addTransitionsToQueue(transitions: transitions)
    }
    
    /// Remove 1 transition from this RouterView's transition queue.
    @MainActor public func removeTransitionFromQueue(id: String) {
        object.removeTransitionsFromQueue(ids: [id])
    }
    
    /// Remove mulitple transitions from this RouterView's transition queue.
    @MainActor public func removeTransitionsFromQueue(ids: [String]) {
        object.removeTransitionsFromQueue(ids: ids)
    }
    
    /// Remove all transitions from this RouterView's transition queue.
    @MainActor public func removeAllTransitionsFromQueue() {
        object.removeAllTransitionsFromQueue()
    }
    
    /// Show the first transition in this RouterView's transition queue, if available.
    @MainActor public func showNextTransition() {
        object.showNextTransition()
    }
    
    /// Show the first transition in this RouterView's transition queue, otherwise throw an error.
    @MainActor public func tryShowNextTransition() throws {
        guard hasTransitionInQueue else {
            throw AnyRouterError.noTransitionsInQueue
        }
        
        object.showNextTransition()
    }
    
    /// Show the first transition in this RouterView's transition queue, otherwise show next screen, otherwise dismiss screen.
    @MainActor public func showNextTransitionOrNextScreenOrDismissScreen() throws {
        do {
            try tryShowNextTransition()
        } catch {
            do {
                try tryShowNextScreen()
            } catch {
                dismissScreen()
            }
        }
    }
    
    enum AnyRouterError: Error {
        case noTransitionsInQueue
        case noScreensInQueue
    }
    
    /// Transition current module.
    /// - Parameters:
    ///   - transition: Transition animation option.
    ///   - id: Identifier for transition id.
    ///   - allowsSwipeBack: Add a swipe-back gesture to the edge of the screen. Note: only works with .trailing or .leading transitions.
    ///   - onDismiss: Closure that triggers when transition is dismissed.
    ///   - destination: Destination screen.
    @MainActor public func showModule<T>(
        _ transition: TransitionOption,
        id: String = UUID().uuidString,
        onDismiss: (() -> Void)? = nil,
        destination: @escaping (AnyRouter) -> T
    ) where T : View {
        let module = AnyTransitionDestination(id: id, transition: transition, destination: destination)
        object.showModule(module: module)
    }
    
    /// Transition current module.
    @MainActor public func showModule(module: AnyTransitionDestination) {
        object.showModule(module: module)
    }
    
    /// Transition current module.
    @MainActor public func showModule(_ module: AnyTransitionDestination) {
        object.showModule(module: module)
    }
    
    /// Transition current module, adding multiple modules to heirarchy, and displaying the last one.
    @MainActor public func showModules(modules: [AnyTransitionDestination]) {
        object.showModules(modules: modules)
    }
    
    /// Dismiss the last module in this RouterView's heirarchy.
    @MainActor public func dismissModule() {
        object.dismissModule()
    }
    
    /// Dismiss all modules after and including module id.
    @MainActor public func dismissModule(id: String) {
        object.dismissModule(id: id)
    }
    
    /// Dismiss all modules after, but not including module id.
    @MainActor public func dismissModules(upToId: String) {
        object.dismissModules(upToId: upToId)
    }
    
    /// Dismiss specific number of modules.
    @MainActor public func dismissModules(count: Int) {
        object.dismissModules(count: count)
    }
    
    /// Dismiss all modules.
    @MainActor public func dismissAllModules() {
        object.dismissAllModules()
    }

    /// Open URL in Safari app. To open url in in-app browser, use showSheet with a WebView.
    func showSafari(_ url: @escaping () -> URL) {
        object.showSafari(url)
    }

}
