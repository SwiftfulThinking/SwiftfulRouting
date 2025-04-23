//
//  RouterViewModel.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

@MainActor
final class RouterViewModel: ObservableObject {
    static let rootId = "root"
    
    @Published private(set) var rootRouterIdFromDeveloper: String? = nil
    
    // Active screen stack heirarchy. See AnyDestinationStack.swift for documentation.
    @Published private(set) var activeScreenStacks: [AnyDestinationStack] = [AnyDestinationStack(segue: .push, screens: [])]
    
    // Available screens in queue, accessible via .showNextScreen()
    @Published private(set) var availableScreenQueue: [AnyDestination] = []
    
    // Active alerts for all child screens. Each screen can have only one active alert.
    // [routerId : Alert]
    @Published private(set) var activeAlert: [String: AnyAlert] = [:]
    
    // All modals for all child screens. Each screen can have multiple modals simultaneously.
    // Modals remain in the array even after beign dismissed (ie modal.isRemoved = true)
    // [routerId : [Modals]]
    @Published private(set) var allModals: [String: [AnyModal]] = [:]
    
    // All transitions for all child screens. Each screen can have multiple transitions.
    // Transitions are removed from the array when dismissed.
    // [routerId : [Transitions]]
    @Published private(set) var allTransitions: [String: [AnyTransitionDestination]] = [RouterViewModel.rootId: [.root]]
    
    // The current TransitionOption on each screen.
    // While a transition is rendered, its .transition may change based on the next/previous transition.
    @Published private(set) var currentTransitions: [String: TransitionOption] = [RouterViewModel.rootId: .trailing]
    
    // Available transitions in queue, accessible via .showNextTransition()
    @Published private(set) var availableTransitionQueue: [String: [AnyTransitionDestination]] = [:]
        
    // Only called once onFirstAppear in the root router.
    // This replaces starting activeScreenStacks value.
    // It MUST be called after the screen appears, since it is adding the View itself to the array.
    func insertRootView(rootRouterId: String?, view: AnyDestination) {
        activeScreenStacks.insert(AnyDestinationStack(segue: .fullScreenCover, screens: [view]), at: 0)
        rootRouterIdFromDeveloper = rootRouterId
        logger.trackEvent(event: Event.screenShow(screen: view, rootRouterId: rootRouterIdFromDeveloper))
    }
    
}

// MARK: EVENTS

extension RouterViewModel {
    
    @MainActor
    enum Event: RoutingLogEvent {
        case showScreen_routerIdNotFound(id: String)
        case screenQueue_routerIdNotFound(id: String)
        case dismissScreen_routerIdNotFound(id: String)
        case dismissLastScreen_noScreenToDismiss
        case dismissScreensCount_noScreenToDismiss(countRequested: Int, countDismissed: Int)
        case dismissEnvironment_noEnvironmentToDismiss(id: String)
        case dismissPushStack_noPushStack(id: String)
        case dismissLastModal_noModals(routerId: String)
        case dismissModal_modalNotFound(routerId: String, modalId: String)
        case dismissModalsAbove_noneFound(routerId: String, modalId: String)
        case dismissModalsCount_noneToDismiss(countRequested: Int, countDismissed: Int)
        case dismissTransition_notFound(routerId: String)
        case dismissTransitions_notFound(routerId: String, transitionId: String)
        case dismissTransitionsTo_notFound(routerId: String, transitionId: String)
        case dismissTransitionsTo_empty(routerId: String, transitionId: String)
        case dismissTransitionsCount_none(routerId: String, count: Int)
        case dismissTransitionsCount_notFound(routerId: String, count: Int)
        case dismissTransitionsCount_empty(routerId: String, count: Int)
        case dismissAllTransitions_none(routerId: String)
        case dismissAllTransitions_empty(routerId: String)
        case showNextScreen_emptyQueue(routerId: String)
        case showNextTransition_emptyQueue(routerId: String)
        
        // Info logging
        case screenStackUpdated(newValue: String)
        case screenQueueUpdated(newValue: String)
        case modalStackUpdated(routerId: String, newValue: String)
        case transitionStackUpdated(routerId: String, newValue: String)
        case transitionQueueUpdated(routerId: String, newValue: String)
        
        // Analytics
        case screenShow(screen: AnyDestination, rootRouterId: String?)
        case screenDismiss(screen: AnyDestination, rootRouterId: String?)
        case alertShow(alert: AnyAlert)
        case alertDismiss(alert: AnyAlert)
        case modalShow(modal: AnyModal)
        case modalDismiss(modal: AnyModal)
        case transitionShow(transition: AnyTransitionDestination)
        case transitionDismiss(transition: AnyTransitionDestination)
        case showSafari(url: URL)


        var eventName: String {
            switch self {
            case .showScreen_routerIdNotFound:                          return "Routing_ShowScreen_RouterIdNotFound"
            case .screenQueue_routerIdNotFound:                         return "Routing_ScreenQueue_RouterIdNotFound"
            case .dismissScreen_routerIdNotFound:                       return "Routing_DismissScreen_RouterIdNotFound"
            case .dismissLastScreen_noScreenToDismiss:                  return "Routing_DismissLastScreen_ScreenNotFound"
            case .dismissScreensCount_noScreenToDismiss:                return "Routing_DismissScreenScount_CountNotFound"
            case .dismissEnvironment_noEnvironmentToDismiss:            return "Routing_DismissEnvironment_EnvNotFound"
            case .dismissPushStack_noPushStack:                         return "Routing_DismissPushStack_StackNotFound"
            case .dismissLastModal_noModals:                            return "Routing_DismissLastModal_NoneFound"
            case .dismissModal_modalNotFound:                           return "Routing_DismissModal_NotFound"
            case .dismissModalsAbove_noneFound:                         return "Routing_DismissModalsAbove_NoneFound"
            case .dismissModalsCount_noneToDismiss:                     return "Routing_DismissModalsCount_CountNotFound"
            case .dismissTransition_notFound:                           return "Routing_DismissTransition_NotFound"
            case .dismissTransitions_notFound:                          return "Routing_DismissTransitions_NotFound"
            case .dismissTransitionsTo_notFound:                        return "Routing_DismissTransitionsTo_NotFound"
            case .dismissTransitionsTo_empty:                           return "Routing_DismissTransitionsTo_EmptyArray"
            case .dismissTransitionsCount_none:                         return "Routing_DismissTransitionsCount_None"
            case .dismissTransitionsCount_notFound:                     return "Routing_DismissTransitionsCount_NotFound"
            case .dismissTransitionsCount_empty:                        return "Routing_DismissTransitionsCount_Empty"
            case .dismissAllTransitions_none:                           return "Routing_DismissAllTransitions_None"
            case .dismissAllTransitions_empty:                          return "Routing_DismissAllTransitions_Empty"
            case .showNextScreen_emptyQueue:                            return "Routing_ShowNextScreen_EmptyQueue"
            case .showNextTransition_emptyQueue:                        return "Routing_ShowNextTransition_EmptyQueue"
            case .screenStackUpdated:                                   return "Routing_ScreenStack_Updated"
            case .screenQueueUpdated:                                   return "Routing_ScreenQueue_Updated"
            case .modalStackUpdated:                                    return "Routing_ModalStack_Updated"
            case .transitionStackUpdated:                               return "Routing_TransitionStack_Updated"
            case .transitionQueueUpdated:                               return "Routing_TransitionQueue_Updated"
            case .screenShow:                                           return "Routing_Screen_Appear"
            case .screenDismiss:                                        return "Routing_Screen_Dismiss"
            case .alertShow:                                            return "Routing_Alert_Appear"
            case .alertDismiss:                                         return "Routing_Alert_Dismiss"
            case .modalShow:                                            return "Routing_Modal_Appear"
            case .modalDismiss:                                         return "Routing_Modal_Dismiss"
            case .transitionShow:                                       return "Routing_Transition_Appear"
            case .transitionDismiss:                                    return "Routing_Transition_Dismiss"
            case .showSafari:                                           return "Routing_Safari_Show"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .showScreen_routerIdNotFound(id: let id), .screenQueue_routerIdNotFound(id: let id), .dismissScreen_routerIdNotFound(id: let id), .dismissEnvironment_noEnvironmentToDismiss(id: let id), .dismissPushStack_noPushStack(id: let id), .dismissLastModal_noModals(routerId: let id), .dismissTransition_notFound(routerId: let id), .dismissAllTransitions_none(routerId: let id), .dismissAllTransitions_empty(routerId: let id), .showNextScreen_emptyQueue(routerId: let id), .showNextTransition_emptyQueue(routerId: let id):
                return [
                    "router_id": id
                ]
            case .dismissModal_modalNotFound(routerId: let routerId, modalId: let modalId), .dismissModalsAbove_noneFound(routerId: let routerId, modalId: let modalId):
                return [
                    "router_id": routerId,
                    "modal_id": modalId
                ]
            case .dismissTransitions_notFound(routerId: let routerId, transitionId: let transitionId), .dismissTransitionsTo_notFound(routerId: let routerId, transitionId: let transitionId), .dismissTransitionsTo_empty(routerId: let routerId, transitionId: let transitionId):
                return [
                    "router_id": routerId,
                    "transition_id": transitionId
                ]
            case .dismissScreensCount_noScreenToDismiss(countRequested: let requested, countDismissed: let dismissed), .dismissModalsCount_noneToDismiss(countRequested: let requested, countDismissed: let dismissed):
                return [
                    "dismiss_requested_count": requested,
                    "dismiss_success_count": dismissed
                ]
            case .dismissTransitionsCount_none(routerId: let routerId, count: let count), .dismissTransitionsCount_notFound(routerId: let routerId, count: let count), .dismissTransitionsCount_empty(routerId: let routerId, count: let count):
                return [
                    "router_id": routerId,
                    "dismiss_requested_count": count
                ]
            case .screenStackUpdated(newValue: let newValue):
                return [
                    "screen_stack": newValue
                ]
            case .screenQueueUpdated(newValue: let newValue):
                return [
                    "screen_queue": newValue
                ]
            case .modalStackUpdated(routerId: let routerId, newValue: let newValue):
                return [
                    "router_id": routerId,
                    "modal_stack": newValue
                ]
            case .transitionStackUpdated(routerId: let routerId, newValue: let newValue):
                return [
                    "router_id": routerId,
                    "transition_stack": newValue
                ]
            case .transitionQueueUpdated(routerId: let routerId, newValue: let newValue):
                return [
                    "router_id": routerId,
                    "transition_queue": newValue
                ]
            case .screenShow(screen: let screen, rootRouterId: let rootId), .screenDismiss(screen: let screen, rootRouterId: let rootId):
                var screen = screen
                if let rootId, screen.id == RouterViewModel.rootId {
                    screen.updateScreenId(newValue: rootId)
                }
                return screen.eventParameters
            case .alertShow(alert: let alert), .alertDismiss(alert: let alert):
                return alert.eventParameters
            case .modalShow(modal: let modal), .modalDismiss(modal: let modal):
                return modal.eventParameters
            case .transitionShow(transition: let transition), .transitionDismiss(transition: let transition):
                return transition.eventParameters
            case .showSafari(url: let url):
                return [
                    "url_string": url.absoluteString
                ]
            default:
                return nil
            }
        }
        
        var type: RoutingLogType {
            switch self {
            case .screenStackUpdated, .screenQueueUpdated, .modalStackUpdated, .transitionStackUpdated, .transitionQueueUpdated:
                return .info
            case .screenShow, .screenDismiss, .alertShow, .alertDismiss, .modalShow, .modalDismiss, .transitionShow, .transitionDismiss:
                return .analytic
            default:
                return .warning
            }
        }
    }

}

// MARK: SEGUE METHODS

extension RouterViewModel {
    
    // MARK: SEGUE - PUBLIC
        
    // Immediately show the destination screens in order
    func showScreens(routerId: String, destinations: [AnyDestination]) {
        Task {
            var lastRouterId = routerId
            var lastSegue: SegueOption? = nil
            
            for destination in destinations {
                if lastSegue?.presentsNewEnvironment == true {
                    // If there is a .push after a new environment, the OS needs a slight delay before it will animate (idk why)
                    // Also needs a delay if 2 new environments back to back
                    // However, it works without delay if there is no animation
                    if (destination.segue == .push || destination.segue.presentsNewEnvironment) && destination.animates  {
                        try? await Task.sleep(for: .seconds(0.55))
                    }
                }
                
                // Segue to destination
                showScreen(routerId: lastRouterId, destination: destination)
                
                // After each loop, that screen is presented, so next showScreen should be the presented screen's routerId
                lastRouterId = destination.id
                lastSegue = destination.segue
            }
        }
    }

    // MARK: SEGUE - PRIVATE
    
    // Immediately show the destination screen
    private func showScreen(routerId: String, destination: AnyDestination) {
        
        // 1. Get the index within the activeScreenStacks that we will edit
        let stackIndex: Int
        switch destination.location {
        case .insert:
            guard let index = activeScreenStacks.lastIndexWhereChildStackContains(routerId: routerId) else {
                logger.trackEvent(event: Event.showScreen_routerIdNotFound(id: routerId))
                return
            }

            stackIndex = index
        case .insertAfter(id: let requestedRouterId):
            guard let index = activeScreenStacks.lastIndexWhereChildStackContains(routerId: requestedRouterId) else {
                logger.trackEvent(event: Event.showScreen_routerIdNotFound(id: requestedRouterId))
                return
            }

            stackIndex = index
        case .append:
            guard let index = activeScreenStacks.indices.last else {
                logger.trackEvent(event: Event.showScreen_routerIdNotFound(id: "last_id"))
                return
            }
            
            stackIndex = index
        }
        
        // The stack we will edit
        let currentStack = activeScreenStacks[stackIndex]
        
        // Every new screen has a new transition array.
        // We append .root to account for the first screen that will already exist as
        // the screen renders for the first time (ie. the destination).
        allTransitions[destination.id] = [.root]
        
        
        // We have to append the destination differently depending on the segue
        // For more details, see AnyDestinationStack.swift for documentation.
        
        switch destination.segue {
        case .push:
            // If pushing to the next screen...
            //  If currentStack is already a .push stack, then append to it
            //  Otherwise, currentStack is therefore a sheet/fullScreenCover and the associated push stack should be (index + 1)

            // The index where we will attempt to add the new screen
            let appendingIndex: Int = currentStack.segue == .push ? (stackIndex) : (stackIndex + 1)
            
            // Existing screens in this stack (may be empty)
            let existingScreens = activeScreenStacks[appendingIndex].screens
            
            // In addition to the segue type, the developer can customize the insertion location
            // Depending on the location, we alter where exactly we insert
            // The appendingIndex is our anchor but may not be the final index.
            
            func insertPushScreenIntoExistingArray(requestedRouterId: String) {
                // If there are no screens yet, append at the default location.
                guard !existingScreens.isEmpty else {
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.append(destination)
                    }
                    return
                }
                
                // Get the screen index of the current router, so that we can insert after it
                guard let index = existingScreens.firstIndex(where: { $0.id == requestedRouterId }) else {
                    // However, if the index does not exist, then we can assume the requested screen
                    // was the .sheet or .fullScreenCover before this stack
                    // Therefore the next screen above the requested screen in the push stack at index 0

                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.insert(destination, at: 0)
                    }
                    return
                }
                
                
                // If the screenIndex is not last, we can use the insert method
                if existingScreens.indices.contains(index + 1) {
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.insert(destination, at: index + 1)
                    }
                    return
                    
                // If the screenIndex is last, we can use the append method
                } else {
                    triggerAction(withAnimation: destination.animates) {
                        self.activeScreenStacks[appendingIndex].screens.append(destination)
                    }
                    return
                }
            }

            
            switch destination.location {
            case .insert:
                // Insert the screen into the array based on the routerId
                insertPushScreenIntoExistingArray(requestedRouterId: routerId)
                
            case .insertAfter(let requestedRouterId):
                // Insert the screen into the array based on the requestedRouterId
                // Note: Same as .insert case, except using requestedRouterId instead of routerId
                insertPushScreenIntoExistingArray(requestedRouterId: requestedRouterId)

            case .append:
                // If user selects append, we add to the end of the push stack,
                // regardless of where it has been called from!

                triggerAction(withAnimation: destination.animates) {
                    self.activeScreenStacks[appendingIndex].screens.append(destination)
                }
            }
        case .sheetConfig, .fullScreenCoverConfig:
            // If showing sheet or fullScreenCover...
            //  If currentStack is a .push stack, then add a new stack for the environment next (index + 1)
            //  If currentStack is .sheet or .fullScreenCover stack, then the next stack is already a .push, and we add newStack after that (index + 2)
            //
            // When appending a new sheet or fullScreenCover, always append a following .push stack for the new NavigationStack on that environment to bind to
            //
            
            let newStack = AnyDestinationStack(segue: destination.segue, screens: [destination])
            let blankStack = AnyDestinationStack(segue: .push, screens: [])
            let appendingIndex: Int = currentStack.segue == .push ? (stackIndex + 1) : (stackIndex + 2)
            
            triggerAction(withAnimation: destination.animates) {
                self.activeScreenStacks.insert(contentsOf: [newStack, blankStack], at: appendingIndex)
            }
        }
        
        logger.trackEvent(event: Event.screenShow(screen: destination, rootRouterId: rootRouterIdFromDeveloper))
    }
    
    // Utility functino to trigger action with or without SwiftUI animation
    private func triggerAction(withAnimation: Bool, action: @escaping () -> Void) {
        if withAnimation {
            action()
        } else {
            var transaction = Transaction(animation: .none)
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                action()
            }
        }
    }
    
}

// MARK: SEGUE QUEUE

extension RouterViewModel {
    
    // Add screens to segue queue
    func addScreensToQueue(routerId: String, destinations: [AnyDestination]) {
        var insertCounts: [String: Int] = [
            routerId: 0
        ]
        
        for destination in destinations {
            switch destination.location {
            case .append:
                // Append screen to end of queue
                availableScreenQueue.append(destination)
            case .insert:
                // Insert screen to queue at routerId
                //
                // Here we insert screens, but we need to maintain the order of destinations array
                //
                // For example:
                //  If the original is [A, B, C]
                //  And then insert 2 screens at root
                //  Result should be [1, 2, A, B, C]
                //
                //  We cannot call .insert(contentsOf:, at: 0) because each item in loop may be different
                //  We cannot call .insert(at: 0) twice, because it will reverse the order
                //  So, we must call .insert(at: x) twice and move the pointer after each loop
                //
                let index = insertCounts[routerId] ?? 0
                availableScreenQueue.insert(destination, at: index)
                insertCounts[routerId] = index + 1
            case .insertAfter(id: let requestedId):
                // Same as above, except use requestedId
                
                // Try to find requestedId within the screen queue
                if let requestedIsInQueueIndex = availableScreenQueue.firstIndex(where: { $0.id == requestedId }) {
                    let index = Int(requestedIsInQueueIndex) + 1 + (insertCounts[requestedId] ?? 0)
                    availableScreenQueue.insert(destination, at: index)
                    insertCounts[requestedId] = index + 1
                    
                    // Otherwise, track an error and do not append the screen
                } else {
                    logger.trackEvent(event: Event.screenQueue_routerIdNotFound(id: requestedId))
                    
                    // Note: previous iteration would fall-back to append screen to based on routerId
                    // However, this is more confusing for the developer when using showNextScreen()
                    // Better to not append and send a warning message.
                    //
                    // let index = insertCounts[routerId] ?? 0
                    // availableScreenQueue.insert(destination, at: index)
                    // insertCounts[routerId] = index + 1
                }
            }
        }
    }
    
    // Remove screens from screen queue
    func removeScreensFromQueue(screenIds: [String]) {
        for screenId in screenIds {
            availableScreenQueue.removeAll(where: { $0.id == screenId })
        }
    }
    
    // Remove all screens from screen queue
    func removeAllScreensFromQueue() {
        availableScreenQueue.removeAll()
    }
    
    // Show the next screen in queue, if available
    func showNextScreen(routerId: String) {
        guard let nextScreen = availableScreenQueue.first else {
            logger.trackEvent(event: Event.showNextScreen_emptyQueue(routerId: routerId))
            return
        }
        
        showScreen(routerId: routerId, destination: nextScreen)
        availableScreenQueue.removeFirst()
    }
    
}

// MARK: SEGUE DISMISS

extension RouterViewModel {
    
    // Removes all stacks after stackIndex. Keeps stacks up-to and including the stackIndex.
    private func removeAllStacksAsNeeded(stacks: [AnyDestinationStack], stackIndex: Int) -> (keep: [AnyDestinationStack], remove: [AnyDestinationStack]) {
        
        // Ensure the index is within bounds
        guard stackIndex >= 0 && stackIndex < stacks.count else {
            // If the index is out of bounds, return all stacks as "keep" and none as "remove"
            return (keep: stacks, remove: [])
        }
        
        let currentStack = stacks[stackIndex]
        if currentStack.screens.count > 1 {
            // If there is more than 1 screen on this stack
            // Remove all screens after the currentStack
            // Do not remove the currentStack
            
            let keep = Array(stacks[...stackIndex])            // Includes up to and including the stackIndex
            let remove = Array(stacks[(stackIndex + 1)...])    // Includes all after stackIndex
            return (keep, remove)
        } else {
            // If there is 1 or less screens on this stack
            // Remove all screens after and including the currentStack
            // Will remove the currentStack

            let keep = Array(stacks[..<stackIndex])            // Includes stacks before the current stackIndex
            let remove = Array(stacks[stackIndex...])          // Includes the current stack and all after it
            return (keep, remove)
        }
    }
    
    // Remove screen at screenIndex and all screens after screenIndex. Keeps all screens before the screenIndex.
    private func removeScreensAsNeeded(stack: AnyDestinationStack, screenIndex: Int) -> (keep: AnyDestinationStack, remove: [AnyDestination]) {
        let screens: [AnyDestination] = stack.screens
        
        // Ensure the index is within bounds
        guard screenIndex >= 0 && screenIndex < screens.count else {
            // If the index is out of bounds, keep all screens and remove none
            return (keep: stack, remove: [])
        }
        
        // Split the screens array into keep and remove parts
        let keepScreens = Array(screens[..<screenIndex]) // Keep all screens before screenIndex
        let removeScreens = Array(screens[screenIndex...]) // Remove the current screen and all after it
        
        // Create a new stack with the remaining screens
        let keepStack = AnyDestinationStack(segue: stack.segue, screens: keepScreens)
        
        return (keep: keepStack, remove: removeScreens)
    }
    
    // Dismiss screen at routeId and all screens in front of it.
    func dismissScreen(routeId: String, animates: Bool) {
        guard routeId != RouterViewModel.rootId else { return }
        
        for (stackIndex, stack) in activeScreenStacks.enumerated().reversed() {
            // Check if stack.screens contains the routeId
            // Loop from last, in case there are multiple screens in the stack with the same routeId (should not happen)
            if let screenIndex = stack.screens.lastIndex(where: { $0.id == routeId }) {
                
                var (keep, remove) = removeAllStacksAsNeeded(stacks: activeScreenStacks, stackIndex: stackIndex)
                var screensToDismiss = remove.flatMap({ $0.screens })
                
                // If the currentStack is still here, then it was not removed
                // Now we need to trim current stack as well
                if keep.indices.contains(stackIndex) {
                    let currentStack = keep[stackIndex]
                    let (currentStackUpdated, removeScreens) = removeScreensAsNeeded(stack: currentStack, screenIndex: screenIndex)
                    
                    // Update currentStack without current screen
                    keep[stackIndex] = currentStackUpdated
                    
                    // Append more screen to remove
                    if !removeScreens.isEmpty {
                        screensToDismiss.insert(contentsOf: removeScreens, at: 0)
                    }
                }
                
                // There should always be a blank pushable stack for the NavigationStack to bind to
                if keep.last?.segue != .push {
                    keep.append(AnyDestinationStack(segue: .push, screens: []))
                }
                
                // Publish update to the view
                triggerAction(withAnimation: animates) {
                    self.activeScreenStacks = keep
                }
                
                // Trigger screen onDismiss closures, if available
                for screen in screensToDismiss.reversed() {
                    screen.onDismiss?()
                    logger.trackEvent(event: Event.screenDismiss(screen: screen, rootRouterId: rootRouterIdFromDeveloper))
                }
                
                if let newScreenShowing = activeScreenStacks.allScreens.last {
                    logger.trackEvent(event: Event.screenShow(screen: newScreenShowing, rootRouterId: rootRouterIdFromDeveloper))
                }

                // Stop loop
                return
            }
        }
        
        // Error: could not dismiss screen
        logger.trackEvent(event: Event.dismissScreen_routerIdNotFound(id: routeId))
    }
    
    // Dismiss all screens in front of routeId
    func dismissScreens(toEnvironmentId routeId: String, animates: Bool) {
        // This is called "onDismiss" of a .sheet or .fullScreenCover (dismissing the environment in front of routeId)
        // It is called internally and not by the user
        // When an environment dismisses, everthing in front of it should be dismissed
        //
        // Note: if the user used a dismissScreen() to dismiss, then the screens may already be removed
        // However, if the user swiped down a sheet manually, this method will catch the discrepency and update the stacks accordingly

        // Find the stack that contains the routeId
        if let stackIndex = activeScreenStacks.firstIndex(where: { $0.screens.contains(where: { $0.id == routeId }) }) {
            
            // If there are stacks in front of stackIndex, dismiss them
            if activeScreenStacks.indices.contains(stackIndex + 1) {
                let nextStack = activeScreenStacks[stackIndex + 1]
                if let lastScreen = nextStack.screens.last {
                    dismissScreens(to: lastScreen.id, animates: animates)
                    return
                }
            }
            
            // Fall-back, if it is the last stack, dismiss to this stack
            // Shouldn't do anything but is a safety mechanism?
            if let lastScreen = activeScreenStacks[stackIndex].screens.last {
                dismissScreens(to: lastScreen.id, animates: animates)
                return
            }
        }
        
        // It is NOT a problem if this method finishes without dismissing screens.
        // This occurs if user programatically dismissed screens.
        // This method is primarily for users manually swipeing to dismiss.
    }
    
    // Dismiss all screens in front of routeId and leave routeId as the remaining active screen.
    func dismissScreens(to routeId: String, animates: Bool) {
        // The parameter routeId should be the remaining screen after dismissing all screens in front of it
        // So we call dismissScreen(routeId:) with the next screen's routeId
        
        let allScreens = activeScreenStacks.allScreens
        if let screenIndex = allScreens.firstIndex(where: { $0.id == routeId }) {
            if allScreens.indices.contains(screenIndex + 1) {
                let nextRoute = allScreens[screenIndex + 1]
                dismissScreen(routeId: nextRoute.id, animates: animates)
                return
            }
        }
        
        // It is NOT a problem if this method finishes without dismissing screens.
    }
    
    /// Dismiss the last screen presented.
    func dismissLastScreen(animates: Bool) {
        let allScreens = activeScreenStacks.allScreens
        if let lastScreen = allScreens.last {
            dismissScreen(routeId: lastScreen.id, animates: animates)
            return
        }
        
        logger.trackEvent(event: Event.dismissLastScreen_noScreenToDismiss)
    }
    
    /// Dismiss the last x screens presented.
    func dismissScreens(count: Int, animates: Bool) {
        // Dismiss screens in reverse order (stacking with the last screen)
        let allScreensReversed = activeScreenStacks.allScreens.reversed()
        
        var counter: Int = 0
        for screen in allScreensReversed {
            counter += 1
            
            if counter == count || screen == allScreensReversed.last {
                dismissScreen(routeId: screen.id, animates: animates)
                return
            }
        }
        
        logger.trackEvent(event: Event.dismissScreensCount_noScreenToDismiss(countRequested: count, countDismissed: counter))
    }
    
    // Dismiss the closest .sheet or .fullScreenCover below the routeId.
    func dismissEnvironment(routeId: String, animates: Bool) {
        var didFindScreen: Bool = false
        for stack in activeScreenStacks.reversed() {
            if stack.screens.contains(where: { $0.id == routeId }) {
                didFindScreen = true
            }
            
            if didFindScreen, stack.segue.presentsNewEnvironment, let route = stack.screens.first {
                dismissScreen(routeId: route.id, animates: animates)
                return
            }
        }
        
        logger.trackEvent(event: Event.dismissEnvironment_noEnvironmentToDismiss(id: routeId))
    }
    
    // Dismiss the last .sheet or .fullScreenCover presented.
    func dismissLastEnvironment(animates: Bool) {
        let lastEnvironmentStack = activeScreenStacks.last(where: { $0.segue.presentsNewEnvironment })
        if let route = lastEnvironmentStack?.screens.first {
            dismissScreen(routeId: route.id, animates: animates)
            return
        }
        
        logger.trackEvent(event: Event.dismissEnvironment_noEnvironmentToDismiss(id: "last_environment"))
    }
    
    // Dismiss all .push routes on the current NavigationStack, up-to but not including any .sheet or .fullScreenCover.
    func dismissPushStack(routeId: String, animates: Bool) {
        for (stackIndex, stack) in activeScreenStacks.enumerated().reversed() {
            if stack.screens.contains(where: { $0.id == routeId }) {
                
                // If current stack is .push, dismiss to the first screen in this stack
                if stack.segue == .push, let route = stack.screens.first {
                    dismissScreen(routeId: route.id, animates: animates)
                    return
                }
                
                // If current stack is .sheet or .fullScreenCover, then the .push stack should be the following stack
                if stack.segue.presentsNewEnvironment {
                    if activeScreenStacks.indices.contains(stackIndex + 1) {
                        let nextStack = activeScreenStacks[stackIndex + 1]
                        if nextStack.segue == .push, let route = nextStack.screens.first {
                            dismissScreen(routeId: route.id, animates: animates)
                            return
                        }
                    }
                }
            }
        }
        
        logger.trackEvent(event: Event.dismissPushStack_noPushStack(id: routeId))
    }
    
    // Dismiss all .push routes on the last NavigationStack, up-to but not including any .sheet or .fullScreenCover.
    func dismissLastPushStack(animates: Bool) {
        let lastPushStack = activeScreenStacks.last(where: { $0.segue == .push })
        if let route = lastPushStack?.screens.first {
            dismissScreen(routeId: route.id, animates: animates)
            return
        }
        
        logger.trackEvent(event: Event.dismissPushStack_noPushStack(id: "last_stack"))
    }
    
    // Dismiss all screens back to root.
    func dismissAllScreens(animates: Bool) {
        dismissScreens(to: RouterViewModel.rootId, animates: animates)
    }
    
}

// MARK: ALERT METHODS

extension RouterViewModel {
    
    func showAlert(routerId: String, alert: AnyAlert) {
        var routerId = routerId
        
        // If location is .topScreen, present alert on the last screen displayed
        if alert.location == .topRouter {
            if let lastScreen = activeScreenStacks.allScreens.last {
                routerId = lastScreen.id
            }
        }
        
        if let existingAlert = activeAlert[routerId] {
            // Dismiss current alert and display new alert (should not occur)
            self.activeAlert.removeValue(forKey: routerId)
            logger.trackEvent(event: Event.alertDismiss(alert: existingAlert))
            
            Task {
                try? await Task.sleep(for: .seconds(0.1))
                self.activeAlert[routerId] = alert
            }
        } else {
            // Display alert
            self.activeAlert[routerId] = alert
        }
        
        logger.trackEvent(event: Event.alertShow(alert: alert))
    }
    
    // Dismiss any alert displayed on routerId
    func dismissAlert(routerId: String) {
        if let existingAlert = activeAlert[routerId] {
            // Dismiss current alert and display new alert (should not occur)
            self.activeAlert.removeValue(forKey: routerId)
            logger.trackEvent(event: Event.alertDismiss(alert: existingAlert))
        }
    }
    
    // Dismiss all alerts from all screens
    func dismissAllAlerts() {
        for (key, alert) in activeAlert {
            self.activeAlert.removeValue(forKey: key)
            logger.trackEvent(event: Event.alertDismiss(alert: alert))
        }
    }
    
}

// MARK: MODAL METHODS

extension RouterViewModel {
    
    // Show modal on routerId
    func showModal(routerId: String, modal: AnyModal) {
        var routerId = routerId
        
        switch modal.location {
        case .currentRouter:
            break
        case .topRouter:
            if let lastScreen = activeScreenStacks.allScreens.last {
                routerId = lastScreen.id
            }
        case .bottomRouter:
            if let firstScreen = activeScreenStacks.allScreens.first {
                routerId = firstScreen.id
            }
        }
        
        // Every routerId needs an array if it doesn't have one already
        if allModals[routerId] == nil {
            allModals[routerId] = []
        }
        
        allModals[routerId]!.append(modal)
        logger.trackEvent(event: Event.modalShow(modal: modal))
    }
    
    // Dismiss the last modal on routerId
    func dismissLastModal(onRouterId routerId: String) {
        let allModals = (allModals[routerId] ?? []).filter({ !$0.isRemoved })
        if let lastModal = allModals.last {
            dismissModal(routerId: routerId, modalId: lastModal.id)
            return
        }
        
        logger.trackEvent(event: Event.dismissLastModal_noModals(routerId: routerId))
    }
    
    func dismissModal(routerId: String, modalId: String) {
        if let index = allModals[routerId]?.lastIndex(where: { $0.id == modalId && !$0.isRemoved }), let modal = allModals[routerId]?[index] {
            // Trigger onDismiss for the modal
            modal.onDismiss?()
            
            // Dismiss the modal UI
            // Note: when we 'remove' a modal, we keep the modal in the data array but set isRemoved = true
            // This allows a smooth transition and doesn't corrupt other displayed modals
            // ie. multiple modals can display simultaneously and editing the array indexes would re-render them all.
            allModals[routerId]?[index].convertToEmptyRemovedModal()
            
            logger.trackEvent(event: Event.modalDismiss(modal: modal))
            return
        }
        
        logger.trackEvent(event: Event.dismissModal_modalNotFound(routerId: routerId, modalId: modalId))
    }
    
    // Dismiss all modals above, but not including, the modalId.
    func dismissModals(routerId: String, to modalId: String) {
        // The parameter modalId should be the remaining modal after dismissing all modals in front of it
        // So we call dismissModal(modalId:) with the next screen's routeId
        
        let allModals = allModals[routerId] ?? []
        if let modalIndex = allModals.lastIndex(where: { $0.id == modalId }) {
            // get all modals AFTER modalIndex
            let modalsToDismiss = allModals[(modalIndex + 1)...]
            if !modalsToDismiss.isEmpty {
                
                // Dismiss them in reverse order, starting with the last one (ie. the top-most one)
                for modal in modalsToDismiss.reversed() {
                    if !modal.isRemoved {
                        dismissModal(routerId: routerId, modalId: modal.id)
                    }
                }
                return
            }
        }
        
        logger.trackEvent(event: Event.dismissModalsAbove_noneFound(routerId: routerId, modalId: modalId))
    }
    
    // Dismiss last x modals
    func dismissModals(routerId: String, count: Int) {
        let allModalsReversed = (allModals[routerId] ?? []).reversed()
        
        var counter: Int = 0
        for modal in allModalsReversed {
            if !modal.isRemoved {
                counter += 1
                dismissModal(routerId: routerId, modalId: modal.id)
            }
            
            if counter == count {
                return
            }
        }
        
        logger.trackEvent(event: Event.dismissModalsCount_noneToDismiss(countRequested: count, countDismissed: counter))
    }
    
    // Dismiss all modals on routerId
    func dismissAllModals(routerId: String) {
        let allModalsReversed = (allModals[routerId] ?? []).reversed()
        
        for modal in allModalsReversed {
            if !modal.isRemoved {
                dismissModal(routerId: routerId, modalId: modal.id)
            }
        }
    }
    
}
 
// MARK: TRANSITION METHODS

extension RouterViewModel {
    
    // Show transition on routerId
    func showTransition(routerId: String, transition: AnyTransitionDestination) {
        // Set the current transition before triggering the UI update
        // This can change the existing screen's "removal" transition, based on the incomign screens transition
        self.currentTransitions[routerId] = transition.transition
        
        Task { @MainActor in
            // The OS needs a slight delay to update the existing screen's transition
            try? await Task.sleep(nanoseconds: 1_000_000)
            
            // Trigger the UI update
            // allTransitions[routerId] should never be nil since it's added in showScreen
            self.allTransitions[routerId]?.append(transition)
            logger.trackEvent(event: Event.transitionShow(transition: transition))
        }
    }
    
    // Show array of transitions simultanously on routerId
    func showTransitions(routerId: String, transitions: [AnyTransitionDestination]) {
        // Removal of existing screen is based on the last transition requested (ie. the top-most transition)
        guard let lastTransition = transitions.last else { return }
        
        // Same as above (showTransition)
        
        self.currentTransitions[routerId] = lastTransition.transition
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000)
            self.allTransitions[routerId]?.append(contentsOf: transitions)
            logger.trackEvent(event: Event.transitionShow(transition: lastTransition))
        }
    }
    
}

// MARK: TRANSITION QUEUE

extension RouterViewModel {
    
    // Add transitions to queue
    func addTransitionsToQueue(routerId: String, transitions: [AnyTransitionDestination]) {
        if availableTransitionQueue[routerId] == nil {
            availableTransitionQueue[routerId] = []
        }
        
        availableTransitionQueue[routerId]?.append(contentsOf: transitions)
    }
    
    // Remove requested transitions from queue
    func removeTransitionsFromQueue(routerId: String, transitionIds: [String]) {
        for transitionId in transitionIds {
            availableTransitionQueue[routerId]?.removeAll(where: { $0.id == transitionId })
        }
    }
    
    // Remove all transitions from queue
    func removeAllTransitionsFromQueue(routerId: String) {
        availableTransitionQueue[routerId]?.removeAll()
    }

    // Show next transition from queue, if available
    func showNextTransition(routerId: String) {
        guard let nextTransition = availableTransitionQueue[routerId]?.first else {
            logger.trackEvent(event: Event.showNextTransition_emptyQueue(routerId: routerId))
            return
        }
        
        showTransition(routerId: routerId, transition: nextTransition)
        availableTransitionQueue[routerId]?.removeFirst()
    }
}

// MARK: TRANSITION DISMISS

extension RouterViewModel {
    
    // Dismiss last transition on routerId
    func dismissTransition(routerId: String) {
        let transitions = allTransitions[routerId] ?? []
        
        guard let index = transitions.indices.last, transitions.indices.contains(index - 1) else {
            // no transition to dismiss
            logger.trackEvent(event: Event.dismissTransition_notFound(routerId: routerId))
            return
        }
        
        triggerAndRemoveTransitions(
            routerId: routerId,
            newCurrentTransition: transitions[index].transition.reversed,
            screensToDismiss: [transitions[index]],
            removeTransitionsAtRange: index..<index + 1
        )
    }
    
    private func triggerAndRemoveTransitions(routerId: String, newCurrentTransition: TransitionOption, screensToDismiss: [AnyTransitionDestination], removeTransitionsAtRange: Range<Int>) {
        // Set current transition
        self.currentTransitions[routerId] = newCurrentTransition
        
        // Task is needed for UI
        Task { @MainActor in
            // Not required but doesn't hurt?
            try? await Task.sleep(nanoseconds: 1_000_000)
            
            defer {
                for screen in screensToDismiss.reversed() {
                    // Trigger onDismiss for screens
                    screen.onDismiss?()
                    logger.trackEvent(event: Event.transitionDismiss(transition: screen))
                }
            }
            
            // Trigger UI update
            self.allTransitions[routerId]?.removeSubrange(removeTransitionsAtRange)
        }
    }
    
    // Dismiss transition at transitionId and all transitions in front of it
    func dismissTransitions(routerId: String, transitionId: String) {
        // Dismiss to the screen before id
        guard
            let transitions = allTransitions[routerId],
            let requestedIndex = transitions.firstIndex(where: {  $0.id == transitionId }) else {
            logger.trackEvent(event: Event.dismissTransitions_notFound(routerId: routerId, transitionId: transitionId))
            return
        }
        
        // If there are no transitions before requestedIndex
        // Then fall-back to dismiss back to root
        var resultingScreenId = RouterViewModel.rootId
        if transitions.indices.contains(requestedIndex - 1) {
            resultingScreenId = transitions[requestedIndex - 1].id
        }
        
        dismissTransitions(routerId: routerId, toTransitionId: resultingScreenId)
    }
    
    // Dismiss transitions after, but not including, toTransitionId
    func dismissTransitions(routerId: String, toTransitionId: String) {
        let transitions = allTransitions[routerId] ?? []
        
        guard
            // Get the last transition (array shoudl not be empty)
            let lastIndex = transitions.indices.last,
            // Array must contain more than 1 item, otherwise nothing to dismiss
            transitions.indices.contains(lastIndex - 1),
            // Find screen to dismiss to
            let screenIndex = transitions.firstIndex(where: { $0.id == toTransitionId })
        else {
            logger.trackEvent(event: Event.dismissTransitionsTo_notFound(routerId: routerId, transitionId: toTransitionId))
            return
        }
        
        let screensToDismissStartingIndex = (screenIndex + 1)
        let screensToDismiss = Array(transitions[screensToDismissStartingIndex...])
        
        guard !screensToDismiss.isEmpty else {
            logger.trackEvent(event: Event.dismissTransitionsTo_empty(routerId: routerId, transitionId: toTransitionId))
            return
        }
        
        triggerAndRemoveTransitions(
            routerId: routerId,
            newCurrentTransition: transitions[lastIndex].transition.reversed,
            screensToDismiss: screensToDismiss,
            removeTransitionsAtRange: screensToDismissStartingIndex..<transitions.endIndex
        )
    }
    
    // Dismiss x transitions
    func dismissTransitions(routerId: String, count: Int) {
        let transitions = allTransitions[routerId] ?? []
        
        guard let lastIndex = transitions.indices.last, transitions.indices.contains(lastIndex - 1) else {
            logger.trackEvent(event: Event.dismissTransitionsCount_none(routerId: routerId, count: count))
            return
        }
        
        var counter: Int = 0
        var screensToDismissStartingIndex: Int? = nil
        for (index, _) in transitions.enumerated().reversed() {
            if counter == count {
                break
            }
            
            counter += 1
            screensToDismissStartingIndex = index
        }
        
        guard var screensToDismissStartingIndex else {
            logger.trackEvent(event: Event.dismissTransitionsCount_notFound(routerId: routerId, count: count))
            return
        }
        
        // Never dismiss root
        screensToDismissStartingIndex = max(1, screensToDismissStartingIndex)
        
        let screensToDismiss = Array(transitions[screensToDismissStartingIndex...])
        
        guard !screensToDismiss.isEmpty else {
            logger.trackEvent(event: Event.dismissTransitionsCount_empty(routerId: routerId, count: count))
            return
        }
        
        triggerAndRemoveTransitions(
            routerId: routerId,
            newCurrentTransition: transitions[lastIndex].transition.reversed,
            screensToDismiss: screensToDismiss,
            removeTransitionsAtRange: screensToDismissStartingIndex..<transitions.endIndex
        )
    }
    
    // Dismiss all transitions
    func dismissAllTransitions(routerId: String) {
        let transitions = allTransitions[routerId] ?? []
        
        guard let lastIndex = transitions.indices.last, transitions.indices.contains(lastIndex - 1) else {
            logger.trackEvent(event: Event.dismissAllTransitions_none(routerId: routerId))
            return
        }
        
        let screensToDismissStartingIndex = 1
        let screensToDismiss = Array(transitions[screensToDismissStartingIndex...])
        
        guard !screensToDismiss.isEmpty else {
            logger.trackEvent(event: Event.dismissAllTransitions_empty(routerId: routerId))
            return
        }
        
        triggerAndRemoveTransitions(
            routerId: routerId,
            newCurrentTransition: transitions[lastIndex].transition.reversed,
            screensToDismiss: screensToDismiss,
            removeTransitionsAtRange: screensToDismissStartingIndex..<transitions.endIndex
        )
    }
    
}

// MARK: LOGGING

extension RouterViewModel {
    
    func printScreenStack(screenStack: [AnyDestinationStack]?) {
        var value: String = ""
        
        // For each AnyDestinationStack
        let screenStack = screenStack ?? activeScreenStacks
        for (arrayIndex, item) in screenStack.enumerated() {
            value += "\nstack \(arrayIndex): \(item.segue.stringValue)"
            
            if item.screens.isEmpty {
                value += "\n    no screens"
            } else {
                for (screenIndex, screen) in item.screens.enumerated() {
                    value += "\n    screen \(screenIndex): \(screen.id)"
                }
            }
        }
        value += "\n"
        logger.trackEvent(event: Event.screenStackUpdated(newValue: value))
    }
    
    func printScreenQueue(screenQueue: [AnyDestination]) {
        var value = ""

        if screenQueue.isEmpty {
            value += "\n    no queue"
        } else {
            for (arrayIndex, item) in screenQueue.enumerated() {
                value += "\n    queue \(arrayIndex): \(item.id)"
            }
        }
        value += "\n"
        logger.trackEvent(event: Event.screenQueueUpdated(newValue: value))
    }
    
    func printModalStack(routerId: String, modals: [AnyModal]) {
        var value = ""

        for modal in modals {
            value += "\n    modal \(modal.id)"
        }
        
        value += "\n"
        logger.trackEvent(event: Event.modalStackUpdated(routerId: routerId, newValue: value))
    }

    func printTransitionStack(routerId: String, transitions: [AnyTransitionDestination]) {
        var value = ""

        for transition in transitions {
            value += "\n    transition \(transition.id)"
        }
        
        value += "\n"
        logger.trackEvent(event: Event.transitionStackUpdated(routerId: routerId, newValue: value))
    }
    
    func printTransitionQueue(routerId: String, transitionQueue: [AnyTransitionDestination]) {
        var value = ""

        if transitionQueue.isEmpty {
            value += "\n    no queue"
        } else {
            for (arrayIndex, item) in transitionQueue.enumerated() {
                value += "\n    queue \(arrayIndex): \(item.id)"
            }
        }
        value += "\n"
        logger.trackEvent(event: Event.transitionQueueUpdated(routerId: routerId, newValue: value))
    }
}
