//
//  ModuleViewModel.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

@MainActor
final class ModuleViewModel: ObservableObject {
    
    @Published private(set) var rootModuleIdFromDeveloper: String? = nil

    // All modules
    // Modules are removed from the array when dismissed.
    @Published private(set) var modules: [AnyTransitionDestination] = [.root]
    
    // The current TransitionOption for changing modules.
    @Published private(set) var currentTransition: TransitionOption = .trailing

}

extension ModuleViewModel {
    
    func showModule(module: AnyTransitionDestination) {
        // Set the current transition before triggering the UI update
        // This can change the existing screen's "removal" transition, based on the incomign screens transition
        self.currentTransition = module.transition
        
        Task { @MainActor in
            // The OS needs a slight delay to update the existing screen's transition
            try? await Task.sleep(nanoseconds: 1_000_000)
            
            // Trigger the UI update
            // allTransitions[routerId] should never be nil since it's added in showScreen
            self.modules.append(module)
            self.setLastModuleId()

            logger.trackEvent(event: Event.moduleShow(module: module))
        }
    }
    
    func showModules(modules: [AnyTransitionDestination]) {
        guard let lastModule = modules.last else { return }
        self.currentTransition = lastModule.transition

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000)
            self.modules.append(contentsOf: modules)
            self.setLastModuleId()

            logger.trackEvent(event: Event.moduleShow(module: lastModule))
        }
    }
    
    func dismissModule() {
        guard let index = modules.indices.last, modules.indices.contains(index - 1) else {
            // no transition to dismiss
            logger.trackEvent(event: Event.dismissModule_notFound)
            return
        }
        
        triggerAndRemoveModules(
            newCurrentTransition: modules[index].transition.reversed,
            screensToDismiss: [modules[index]],
            removeModulesAtRange: index..<index + 1
        )
    }
    
    private func triggerAndRemoveModules(newCurrentTransition: TransitionOption, screensToDismiss: [AnyTransitionDestination], removeModulesAtRange: Range<Int>) {
        // Set current transition
        self.currentTransition = newCurrentTransition
        
        // Task is needed for UI
        Task { @MainActor in
            // Not required but doesn't hurt?
            try? await Task.sleep(nanoseconds: 1_000_000)
            
            defer {
                for screen in screensToDismiss.reversed() {
                    // Trigger onDismiss for screens
                    screen.onDismiss?()
                    logger.trackEvent(event: Event.moduleDismiss(module: screen))
                }
            }
            
            // Trigger UI update
            self.modules.removeSubrange(removeModulesAtRange)
            self.setLastModuleId()
        }
    }
    
    private func setLastModuleId() {
        let lastModuleId = modules.last?.id ?? RouterViewModel.rootId
        
        UserDefaults.lastModuleId = lastModuleId
        logger.trackEvent(event: Event.setLastModuleId(moduleId: lastModuleId))
    }
    
    func dismissModules(moduleId: String) {
        // Dismiss to the screen before id
        guard
            let requestedIndex = modules.firstIndex(where: {  $0.id == moduleId }) else {
            logger.trackEvent(event: Event.dismissModules_notFound(moduleId: moduleId))
            return
        }
        
        // If there are no transitions before requestedIndex
        // Then fall-back to dismiss back to root
        var resultingScreenId = RouterViewModel.rootId
        if modules.indices.contains(requestedIndex - 1) {
            resultingScreenId = modules[requestedIndex - 1].id
        }
        
        dismissModules(toModuleId: resultingScreenId)
    }
    
    // Dismiss transitions after, but not including, toTransitionId
    func dismissModules(toModuleId: String) {
        guard
            // Get the last transition (array shoudl not be empty)
            let lastIndex = modules.indices.last,
            // Array must contain more than 1 item, otherwise nothing to dismiss
            modules.indices.contains(lastIndex - 1),
            // Find screen to dismiss to
            let screenIndex = modules.firstIndex(where: { $0.id == toModuleId })
        else {
            logger.trackEvent(event: Event.dismissModulesTo_notFound(moduleId: toModuleId))
            return
        }
        
        let screensToDismissStartingIndex = (screenIndex + 1)
        let screensToDismiss = Array(modules[screensToDismissStartingIndex...])
        
        guard !screensToDismiss.isEmpty else {
            logger.trackEvent(event: Event.dismissModulesTo_empty(moduleId: toModuleId))
            return
        }
        
        triggerAndRemoveModules(
            newCurrentTransition: modules[lastIndex].transition.reversed,
            screensToDismiss: screensToDismiss,
            removeModulesAtRange: screensToDismissStartingIndex..<modules.endIndex
        )
    }
    
    func dismissModules(count: Int) {
        guard let lastIndex = modules.indices.last, modules.indices.contains(lastIndex - 1) else {
            logger.trackEvent(event: Event.dismissModulesCount_none(count: count))
            return
        }
        
        var counter: Int = 0
        var screensToDismissStartingIndex: Int? = nil
        for (index, _) in modules.enumerated().reversed() {
            if counter == count {
                break
            }
            
            counter += 1
            screensToDismissStartingIndex = index
        }
        
        guard var screensToDismissStartingIndex else {
            logger.trackEvent(event: Event.dismissModulesCount_notFound(count: count))
            return
        }
        
        // Never dismiss root
        screensToDismissStartingIndex = max(1, screensToDismissStartingIndex)
        
        let screensToDismiss = Array(modules[screensToDismissStartingIndex...])
        
        guard !screensToDismiss.isEmpty else {
            logger.trackEvent(event: Event.dismissModulesCount_empty(count: count))
            return
        }
        
        triggerAndRemoveModules(
            newCurrentTransition: modules[lastIndex].transition.reversed,
            screensToDismiss: screensToDismiss,
            removeModulesAtRange: screensToDismissStartingIndex..<modules.endIndex
        )
    }
    
    // Dismiss all transitions
    func dismissAllModules() {
        guard let lastIndex = modules.indices.last, modules.indices.contains(lastIndex - 1) else {
            logger.trackEvent(event: Event.dismissAllModules_none)
            return
        }
        
        let screensToDismissStartingIndex = 1
        let screensToDismiss = Array(modules[screensToDismissStartingIndex...])
        
        guard !screensToDismiss.isEmpty else {
            logger.trackEvent(event: Event.dismissAllModules_empty)
            return
        }
        
        triggerAndRemoveModules(
            newCurrentTransition: modules[lastIndex].transition.reversed,
            screensToDismiss: screensToDismiss,
            removeModulesAtRange: screensToDismissStartingIndex..<modules.endIndex
        )
    }
    
    func printModuleStack(modules: [AnyTransitionDestination]) {
        var value = ""

        for module in modules {
            value += "\n    module \(module.id)"
        }
        
        value += "\n"
        logger.trackEvent(event: Event.moduleStackUpdated(newValue: value))
    }

}

extension ModuleViewModel {
    
    @MainActor
    enum Event: RoutingLogEvent {
        case dismissModule_notFound
        case dismissModules_notFound(moduleId: String)
        case dismissModulesTo_notFound(moduleId: String)
        case dismissModulesTo_empty(moduleId: String)
        case dismissModulesCount_none(count: Int)
        case dismissModulesCount_notFound(count: Int)
        case dismissModulesCount_empty(count: Int)
        case dismissAllModules_none
        case dismissAllModules_empty
        case setLastModuleId(moduleId: String)
        
        // Info logging
        case moduleStackUpdated(newValue: String)
    
        // Analytics
        case moduleShow(module: AnyTransitionDestination)
        case moduleDismiss(module: AnyTransitionDestination)

        var eventName: String {
            switch self {
            case .setLastModuleId:                                  return "Routing_SetModuleId"
            case .dismissModule_notFound:                           return "Routing_DismissModule_NotFound"
            case .dismissModules_notFound:                          return "Routing_DismissModules_NotFound"
            case .dismissModulesTo_notFound:                        return "Routing_DismissModulesTo_NotFound"
            case .dismissModulesTo_empty:                           return "Routing_DismissModulesTo_EmptyArray"
            case .dismissModulesCount_none:                         return "Routing_DismissModulesCount_None"
            case .dismissModulesCount_notFound:                     return "Routing_DismissModulesCount_NotFound"
            case .dismissModulesCount_empty:                        return "Routing_DismissModulesCount_Empty"
            case .dismissAllModules_none:                           return "Routing_DismissAllModules_None"
            case .dismissAllModules_empty:                          return "Routing_DismissAllModules_Empty"
            case .moduleStackUpdated:                               return "Routing_ModuleStack_Updated"
            case .moduleShow:                                       return "Routing_Module_Appear"
            case .moduleDismiss:                                    return "Routing_Module_Dismiss"
            }
        }
        
        var parameters: [String : Any]? {
            switch self {
            case .dismissModules_notFound(let moduleId), .dismissModulesTo_notFound(let moduleId), .dismissModulesTo_empty(let moduleId), .setLastModuleId(moduleId: let moduleId):
                return [
                    "module_id": moduleId
                ]
            case .dismissModulesCount_none(let count), .dismissModulesCount_notFound(let count), .dismissModulesCount_empty(let count):
                return [
                    "dismiss_requested_count": count
                ]
            case .moduleStackUpdated(let newValue):
                return [
                    "modules_stack": newValue
                ]
            case .moduleShow(let module), .moduleDismiss(let module):
                return module.eventParameters
            default:
                return nil
            }
        }
        
        var type: RoutingLogType {
            switch self {
            case .moduleStackUpdated, .setLastModuleId:
                return .info
            case .moduleShow, .moduleDismiss:
                return .analytic
            default:
                return .warning
            }
        }
    }

}
