//
//  Router.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//


import SwiftUI

protocol Router: Sendable {
    @MainActor var activeScreens: [AnyDestinationStack] { get }
    @MainActor var activeScreenQueue: [AnyDestination] { get }
    @MainActor var activeAlert: AnyAlert? { get }
    @MainActor var activeModals: [AnyModal] { get }
    @MainActor var activeTransitions: [AnyTransitionDestination] { get }
    @MainActor var activeTransitionQueue: [AnyTransitionDestination] { get }
    
    @MainActor func showScreens(destinations: [AnyDestination])
    @MainActor func dismissScreen(animates: Bool)
    @MainActor func dismissScreen(id: String, animates: Bool)
    @MainActor func dismissScreens(upToId: String, animates: Bool)
    @MainActor func dismissScreens(count: Int, animates: Bool)
    @MainActor func dismissPushStack(animates: Bool)
    @MainActor func dismissEnvironment(animates: Bool)
    @MainActor func dismissLastScreen(animates: Bool)
    @MainActor func dismissLastPushStack(animates: Bool)
    @MainActor func dismissLastEnvironment(animates: Bool)
    @MainActor func dismissAllScreens(animates: Bool)
    
    @MainActor func addScreensToQueue(destinations: [AnyDestination])
    @MainActor func removeScreensFromQueue(ids: [String])
    @MainActor func removeAllScreensFromQueue()
    @MainActor func showNextScreen()
    
    @MainActor func showAlert(alert: AnyAlert)
    @MainActor func dismissAlert()
    @MainActor func dismissAllAlerts()

    @MainActor func showModal(modal: AnyModal)
    @MainActor func dismissModal()
    @MainActor func dismissModal(id: String)
    @MainActor func dismissModals(upToId: String)
    @MainActor func dismissModals(count: Int)
    @MainActor func dismissAllModals()
    
    @MainActor func showTransition(transition: AnyTransitionDestination)
    @MainActor func showTransitions(transitions: [AnyTransitionDestination])
    @MainActor func dismissTransition()
    @MainActor func dismissTransition(id: String)
    @MainActor func dismissTransitions(upToId: String)
    @MainActor func dismissTransitions(count: Int)
    @MainActor func dismissAllTransitions()
    
    @MainActor func addTransitionsToQueue(transitions: [AnyTransitionDestination])
    @MainActor func removeTransitionsFromQueue(ids: [String])
    @MainActor func removeAllTransitionsFromQueue()
    @MainActor func showNextTransition()
    
    @MainActor func showModule(module: AnyTransitionDestination)
    @MainActor func showModules(modules: [AnyTransitionDestination])
    @MainActor func dismissModule()
    @MainActor func dismissModule(id: String)
    @MainActor func dismissModules(upToId: String)
    @MainActor func dismissModules(count: Int)
    @MainActor func dismissAllModules()

    @MainActor func showSafari(_ url: @escaping () -> URL)
}
