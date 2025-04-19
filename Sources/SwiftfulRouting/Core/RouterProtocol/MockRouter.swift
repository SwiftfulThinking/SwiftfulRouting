//
//  MockRouter.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

struct MockRouter: Router {
    let printPrefix = "🕊️ SwiftfulRouting 🕊️ -> "

    private func printError() {
        #if DEBUG
        print(printPrefix + "Please add a RouterView to the View heirarchy before using Router. There is no Router in the environment!")
        #endif
    }
    
    init() {
        
    }
    
    var activeScreens: [AnyDestinationStack] {
        []
    }
    
    var activeScreenQueue: [AnyDestination] {
        []
    }
    
    var activeAlert: AnyAlert? {
        nil
    }
    
    var activeModals: [AnyModal] {
        []
    }
    
    var activeTransitions: [AnyTransitionDestination] {
        []
    }
    
    var activeTransitionQueue: [AnyTransitionDestination] {
        []
    }

    
    func showScreens(destinations: [AnyDestination]) {
        printError()
    }
    
    func dismissScreen(animates: Bool) {
        printError()
    }
    
    func dismissScreen(id: String, animates: Bool) {
        printError()
    }
    
    func dismissScreens(upToScreenId: String, animates: Bool) {
        printError()
    }
    
    func dismissScreens(count: Int, animates: Bool) {
        printError()
    }
    
    func dismissPushStack(animates: Bool) {
        printError()
    }
    
    func dismissEnvironment(animates: Bool) {
        printError()
    }
    
    func dismissLastScreen(animates: Bool) {
        printError()
    }
    
    func dismissLastPushStack(animates: Bool) {
        printError()
    }
    
    func dismissLastEnvironment(animates: Bool) {
        printError()
    }
    
    func dismissAllScreens(animates: Bool) {
        printError()
    }
    
    func addScreensToQueue(destinations: [AnyDestination]) {
        printError()
    }
    
    func removeScreensFromQueue(ids: [String]) {
        printError()
    }
    
    func removeAllScreensFromQueue() {
        printError()
    }
    
    func showNextScreen() {
        printError()
    }
    
    func showAlert(alert: AnyAlert) {
        printError()
    }
    
    func dismissAlert() {
        printError()
    }
    
    func dismissAllAlerts() {
        printError()
    }
    
    func showModal(modal: AnyModal) {
        printError()
    }
    
    func dismissModal() {
        printError()
    }
    
    func dismissModal(id: String) {
        printError()
    }
    
    func dismissModals(upToModalId: String) {
        printError()
    }
    
    func dismissModals(count: Int) {
        printError()
    }
    
    func dismissAllModals() {
        printError()
    }
    
    func showTransition(transition: AnyTransitionDestination) {
        printError()
    }
    
    func showTransitions(transitions: [AnyTransitionDestination]) {
        printError()
    }
    
    func dismissTransition() {
        printError()
    }
    
    func dismissTransition(id: String) {
        printError()
    }
    
    func dismissTransitions(upToId: String) {
        printError()
    }
    
    func dismissTransitions(count: Int) {
        printError()
    }
    
    func dismissAllTransitions() {
        printError()
    }
    
    func addTransitionsToQueue(transitions: [AnyTransitionDestination]) {
        printError()
    }
    
    func removeTransitionsFromQueue(ids: [String]) {
        printError()
    }
    
    func removeAllTransitionsFromQueue() {
        printError()
    }
    
    func showNextTransition() {
        printError()
    }
    
    func showModule(module: AnyTransitionDestination) {
        printError()
    }
    
    func showModules(modules: [AnyTransitionDestination]) {
        printError()
    }
    
    func dismissModule() {
        printError()
    }
    
    func dismissModule(id: String) {
        printError()
    }
    
    func dismissModules(upToId: String) {
        printError()
    }
    
    func dismissModules(count: Int) {
        printError()
    }
    
    func dismissAllModules() {
        printError()
    }
    
    func showSafari(_ url: @escaping () -> URL) {
        printError()
    }
}
