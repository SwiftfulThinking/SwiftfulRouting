//
//  RouterView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

/// RouterView adds modifiers for segues, alerts, and modals. If you are already within a Navigation heirarchy, set addNavigationView = false.
public struct RouterView<T:View>: View {
    
    let addNavigationView: Bool
    let screens: Binding<[AnyDestination]>?
    let content: (AnyRouter) -> T
    
    public init(addNavigationView: Bool = true, screens: (Binding<[AnyDestination]>)? = nil, @ViewBuilder content: @escaping (AnyRouter) -> T) {
        self.addNavigationView = addNavigationView
        self.screens = screens
        self.content = content
    }

    public var body: some View {
        RouterViewInternal(
            addNavigationView: addNavigationView,
            screens: screens,
            route: nil,
            routes: nil,
            environmentRouter: nil,
            content: content
        )
    }
}

struct RouterViewInternal<Content:View>: View, Router {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL

    let addNavigationView: Bool
    let content: (AnyRouter) -> Content
 
    // Routable methods
    @State private var route: AnyRoute

    // Segues
    @State private var segueOption: SegueOption = .push
    @State private var screens: [AnyDestination] = []
    @State private var previousScreens: [AnyDestination] = []
    
    /// routes are all routes set on heirarchy, included ones that are in front of current screen
    @State private var rootRoutes: [[AnyRoute]]
    @Binding private var routes: [[AnyRoute]]
    @State private var environmentRouter: Router?

    // Binding to view stack from previous RouterViews
    @Binding private var screenStack: [AnyDestination]

    // Configuration for resizable sheet on iOS 16+
    // TODO: Move resizable sheet modifiers into a struct "SheetConfiguration"
    // Note: sheet and fullScreenCover bind $dismiss to View in front of them,
    // while resizableSheet binds to the current View itself (possible fix me)
    @State private var sheetDetents: Set<PresentationDetentTransformable> = [.large]
    @State private var sheetSelection: Binding<PresentationDetentTransformable> = .constant(.large)
    @State private var sheetSelectionEnabled: Bool = false
    @State private var showDragIndicator: Bool = false
    @State private var isResizableSheet: Bool = false

    // Alerts
    @State private var alertOption: DialogOption = .alert
    @State private var alert: AnyAlert? = nil
    
    // Modals
    @State private var modals: [AnyModalWithDestination] = [.origin]
        
    public init(addNavigationView: Bool = true, screens: (Binding<[AnyDestination]>)? = nil, route: AnyRoute? = nil, routes: Binding<[[AnyRoute]]>? = nil, environmentRouter: Router? = nil, @ViewBuilder content: @escaping (AnyRouter) -> Content) {
        self.addNavigationView = addNavigationView
        self._screenStack = screens ?? .constant([])
        
        if let route {
            self._route = State(wrappedValue: route)
            
            self._rootRoutes = State(wrappedValue: [[route]])
            self._routes = routes ?? .constant([])
        } else {
            let root = AnyRoute.root
            self._route = State(wrappedValue: root)
            
            self._rootRoutes = State(wrappedValue: [[root]])
            self._routes = routes ?? .constant([])
        }
        
        self._environmentRouter = State(wrappedValue: environmentRouter)
        self.content = content
    }
    
    private var currentRouter: AnyRouter {
        AnyRouter(object: self)
    }
    
    public var body: some View {
        NavigationViewIfNeeded(addNavigationView: addNavigationView, segueOption: segueOption, onDismissCurrentPush: onDismissOfCurrentPush, onDismissLastPush: onDismissOfLastPush, screens: $screens) {
            content(currentRouter)
                .showingScreen(
                    option: segueOption,
                    screens: $screens,
                    screenStack: screenStack,
                    sheetDetents: sheetDetents,
                    sheetSelection: sheetSelection,
                    sheetSelectionEnabled: sheetSelectionEnabled,
                    showDragIndicator: showDragIndicator,
                    onDismiss: onDismissOfSheet
                )
                .onFirstAppear(perform: setEnvironmentRouterIfNeeded)
                .onFirstAppear(perform: {
                    updateRouteIsPresented(route: route, isPresented: true)
                })
                .showingAlert(option: alertOption, item: $alert)
        }
        .showingModal(items: modals, onDismissModal: { info in
            dismissModal(id: info.id)
        })
        .environment(\.router, currentRouter)
    }
            
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView { router in
            Text("Hi")
                .onTapGesture {
                    router.showScreen(.push) { router in
                        Text("Hello, world")
                    }
                }
        }
    }
}

extension View {
    
    @ViewBuilder func showingScreen(
        option: SegueOption,
        screens: Binding<[AnyDestination]>,
        screenStack: [AnyDestination],
        sheetDetents: Set<PresentationDetentTransformable>,
        sheetSelection: Binding<PresentationDetentTransformable>,
        sheetSelectionEnabled: Bool,
        showDragIndicator: Bool,
        onDismiss: (() -> Void)?
        ) -> some View {
            if #available(iOS 14, *) {
                self
                    .modifier(NavigationLinkViewModifier(
                        option: option,
                        screens: screens,
                        shouldAddNavigationDestination: screenStack.isEmpty
                    ))
                    .modifier(SheetViewModifier(
                        option: option,
                        screens: screens,
                        sheetDetents: sheetDetents,
                        sheetSelection: sheetSelection,
                        sheetSelectionEnabled: sheetSelectionEnabled,
                        showDragIndicator: showDragIndicator,
                        onDismiss: onDismiss
                    ))
                    .modifier(FullScreenCoverViewModifier(
                        option: option,
                        screens: screens,
                        onDismiss: onDismiss
                    ))
            } else {
                self
                    .modifier(NavigationLinkViewModifier(
                        option: option,
                        screens: screens,
                        shouldAddNavigationDestination: screenStack.isEmpty
                    ))
                    .modifier(SheetViewModifier(
                        option: option,
                        screens: screens,
                        sheetDetents: sheetDetents,
                        sheetSelection: sheetSelection,
                        sheetSelectionEnabled: sheetSelectionEnabled,
                        showDragIndicator: showDragIndicator,
                        onDismiss: onDismiss
                    ))
            }
    }

    @ViewBuilder func showingAlert(option: DialogOption, item: Binding<AnyAlert?>) -> some View {
        self
            .modifier(ConfirmationDialogViewModifier(option: option, item: item))
            .modifier(AlertViewModifier(option: option, item: item))
    }
    
    func showingModal(items: [AnyModalWithDestination], onDismissModal: @escaping (AnyModalWithDestination) -> Void) -> some View {
        modifier(ModalViewModifier(items: items, onDismissModal: onDismissModal))
    }
    
}

// MARK: Segue

extension RouterViewInternal {
    
    /// Show a flow of screens, segueing to the first route immediately. The following routes can be accessed via 'showNextScreen()'.
    public func enterScreenFlow(_ newRoutes: [AnyRoute]) {
        guard let route = newRoutes.first else {
            print(printPrefix + "You must include at least one Route to enterScreenFlow.")
            return
        }
        
        appendRoutes(newRoutes: newRoutes)
        
        let destination = { router in
            AnyView(route.destination(router))
        }
        
        showScreen(route, destination: destination)
    }
            
    public func showNextScreen() throws {
        guard
            let currentFlow = routes.last(where: { flow in
                return flow.contains(where: { $0.id == route.id })
            }),
            let nextRoute = currentFlow.firstAfter(route)
        else {
            throw RoutableError.noNextScreenSet
        }
        
        let destination = { router in
            AnyView(nextRoute.destination(router))
        }
        
        showScreen(nextRoute, destination: destination)
    }
    
    private enum RoutableError: LocalizedError {
        case noNextScreenSet
    }

    private func showScreen<V:View>(_ route: AnyRoute, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        self.segueOption = route.segue

        if route.segue != .push {
            // Add new Navigation
            // Sheet and FullScreenCover enter new Environments and require a new Navigation to be added, and don't need an environmentRouter because they will host the environment.
            self.sheetDetents = [.large]
            self.sheetSelectionEnabled = false
            self.screens.append(AnyDestination(RouterViewInternal<V>(addNavigationView: true, screens: nil, route: route, routes: routeBinding, environmentRouter: nil, content: destination), onDismiss: nil))
        } else {
            // Using existing Navigation
            // Push continues in the existing Environment and uses the existing Navigation
            
            // iOS 16 uses NavigationStack and can push additional views onto an existing view stack
            if #available(iOS 16, *) {
                if screenStack.isEmpty {
                    // We are in the root Router and should start building on $screens
                    self.screens.append(AnyDestination(RouterViewInternal<V>(addNavigationView: false, screens: $screens, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
                } else {
                    // We are not in the root Router and should continue off of $screenStack
                    self.screenStack.append(AnyDestination(RouterViewInternal<V>(addNavigationView: false, screens: $screenStack, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
                }
                
            // iOS 14/15 uses NavigationView and can only push 1 view at a time
            } else {
                // Push a new screen and don't pass view stack to child view (screens == nil)
                self.screens.append(AnyDestination(RouterViewInternal<V>(addNavigationView: false, screens: nil, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
            }
        }
    }
    
    @available(iOS 16, *)
    public func pushScreenStack(destinations: [PushRoute]) {
        // iOS 16 supports NavigationStack, which can push a stack of views and increment an existing view stack
        self.segueOption = .push
        
        // Loop on injected destinations and add them to localStack
        // If screenStack.isEmpty, we are in the root Router and should start building on $screens
        // Else, we are not in the root Router and should continue off of $screenStack
        var localStack: [AnyDestination] = []
        let bindingStack = screenStack.isEmpty ? $screens : $screenStack
        var localRoutes: [AnyRoute] = []

        let destinations = destinations.map({ $0.asAnyRoute })
        
        destinations.forEach { route in
            localRoutes.append(route)
            
            let view = AnyDestination(RouterViewInternal<AnyView>(addNavigationView: false, screens: bindingStack, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: { router in
                AnyView(route.destination(router))
            }), onDismiss: route.onDismiss)
            localStack.append(view)
        }

        appendRoutes(newRoutes: localRoutes)

        if screenStack.isEmpty {
            self.screens.append(contentsOf: localStack)
        } else {
            self.screenStack.append(contentsOf: localStack)
        }
    }
    
    @available(iOS 16, *)
    public func showResizableSheet<V:View>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool = false, onDismiss: (() -> Void)?, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        let newRoute = AnyRoute(.sheet, onDismiss: onDismiss, destination: destination)

        self.segueOption = newRoute.segue
        self.sheetDetents = sheetDetents
        self.showDragIndicator = showDragIndicator
        self.isResizableSheet = true
        self.appendRoutes(newRoutes: [newRoute])

        // If selection == nil, then need to avoid using sheetSelection modifier
        if let selection {
            self.sheetSelection = selection
            self.sheetSelectionEnabled = true
        } else {
            self.sheetSelectionEnabled = false
        }
        
        self.screens.append(AnyDestination(RouterViewInternal<V>(addNavigationView: true, screens: nil, route: route, routes: routeBinding, environmentRouter: nil, content: destination), onDismiss: nil))
        
        // Resizable binding is within current Router, so onFirstAppear of newRoute will never execute
        // Manually mark as isPresented
        updateRouteIsPresented(route: newRoute, isPresented: true)
    }
                
    public func showSafari(_ url: @escaping () -> URL) {
        openURL(url())
    }

}

// MARK: Route support

extension RouterViewInternal {
        
    private var useRoutesNotRootRoutes: Bool {
        !routes.isEmpty
    }
    
    private var currentRouteArray: [AnyRoute] {
        (useRoutesNotRootRoutes ? routes : rootRoutes).flatMap({ $0 })
    }
    
    private func updateRouteIsPresented(route: AnyRoute, isPresented: Bool) {
        
        func setRouteIsPresented(array: inout [[AnyRoute]]) {
            for (setIndex, set) in array.enumerated() {
                for (index, someRoute) in set.enumerated() {
                    if someRoute.id == route.id {
                        array[setIndex][index].isPresented = isPresented
                        
                        if route.id == self.route.id {
                            self.route.isPresented = isPresented
                        }
                        return
                    }
                }
            }
        }
        
        if useRoutesNotRootRoutes {
            setRouteIsPresented(array: &routes)
        } else {
            setRouteIsPresented(array: &rootRoutes)
        }
    }
        
    private func setEnvironmentRouterIfNeeded() {
        // If this is a new environnent (ie. .sheet or .fullScreenCover) then no previous environmentRouter will be passed in
        // Therefore, this is the start of a new environment and this router will be the environmentRouter
        // The first screen should not have one
        if environmentRouter == nil {
            environmentRouter = self
        }
    }
        
    private func removeRoutingFlowsAfterRoute(_ route: AnyRoute) {
        // Remove all flows (arrays) after current flow
        if useRoutesNotRootRoutes {
            routes.removeArraysAfter(arrayThatIncludesId: route.id)
        } else {
            rootRoutes.removeArraysAfter(arrayThatIncludesId: route.id)
        }
    }
    
    private var routeBinding: Binding<[[AnyRoute]]> {
        if useRoutesNotRootRoutes {
            return $routes
        }
        return $rootRoutes
    }
    
    private func appendRoutes(newRoutes: [AnyRoute]) {
        if useRoutesNotRootRoutes {
            self.routes.append(newRoutes)
        } else {
            self.rootRoutes.append(newRoutes)
        }
    }

}

// MARK: Dismiss

extension RouterViewInternal {
    
    private func onDismissOfLastPush() {
        // This is for onDismiss via NavigationStack
        // This is called within the NavigationStack's root Router, but is dismissing the last screen in the stack
        
        // Remove screen from current Router's screen stack
        // Note: even if below 'route' logic fails, the screen has already been removed from View heirarchy
        // So removing final screen from screens should always occur?
        screens.removeLast()

        // Find the last screen in the heirarchy that is presented and is .push
        // Note: Possible bug - this function finds the last .push, but if dev tries to dismiss a .push below the current environment, it will dismiss the one in the current environment?
        guard let screenToDismiss = currentRouteArray.last(where: { $0.isPresented && $0.segue == .push }) else {
            #if DEBUG
            print(printPrefix + "Failed to dismiss push from NavigationStack. Could not find a screen to dismiss.")
            #endif
            return
        }
        
        dismissScreenAndUpdateRoutes(screen: screenToDismiss)
    }
        
    private func onDismissOfCurrentPush() {
        // This is for onDismiss via NavigationView
        // This is called within the Router of the last screen in in the stack, and is dismissing this screen
        
        guard let screenToDismiss = currentRouteArray.last(where: { $0.isPresented && $0.segue == .push }) else {
            #if DEBUG
            print(printPrefix + "Failed to dismiss .push from NavigationStack. Could not find a screen to dismiss.")
            #endif
            return
        }
        
        // As a safety precaution, check that visible screen == self.route
        if screenToDismiss != route {
            #if DEBUG
            print(printPrefix + "Failed to dismiss push. Visible screen found is not the user's current screen.")
            #endif
            return
        }

        dismissScreenAndUpdateRoutes(screen: screenToDismiss)
    }
    
    private func dismissScreenAndUpdateRoutes(screen screenToDismiss: AnyRoute) {
        // Trigger screen's onDismiss
        screenToDismiss.onDismiss?()
        
        // Set screen to not presented
        updateRouteIsPresented(route: screenToDismiss, isPresented: false)
        
        // New root is the screen before the screen to dismiss
        guard let newRootScreen = currentRouteArray.firstBefore(screenToDismiss) else {
            #if DEBUG
            print(printPrefix + "Failed to remove routing flows after screen dismissal. This may cause undefined behavior.")
            #endif
            return
        }
        
        // Remove flow if needed
        removeRoutingFlowsAfterRoute(newRootScreen)
    }
    
    private func onDismissOfSheet() {
        // This is for onDismiss via Sheet or FullScreenCover
        // This is called within the Router prior to the Router of the sheet being dismissed

        // A Sheet/FullScreenCover represents an 'environment' in SwiftUI (ie. each Sheet has it's own NavigationStack)
        // When an 'environment' is dismissed, we are also dismissing all screens pushed onto that NavigationStack
        // The Sheet being dismissed is actually the firstAfter current route
        guard let allRoutesInFrontOfCurrent = currentRouteArray.allAfter(route)?.filter({ $0.isPresented }) else {
            #if DEBUG
            print(printPrefix + "Failed to execute onDismiss methods and remove routing flows after screen dismissal. This may cause undefined behavior.")
            #endif
            return
        }

        // Dismiss all routes in reverse order
        for route in allRoutesInFrontOfCurrent.reversed() {
            route.onDismiss?()
            updateRouteIsPresented(route: route, isPresented: false)
        }
        
        // Remove flow if needed
        removeRoutingFlowsAfterRoute(route)
    }

    public func dismissScreen() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    public func dismissEnvironment() {
        if let environmentRouter {
            environmentRouter.dismissScreen()
        } else {
            dismissScreen()
        }
    }
    
    @available(iOS 16, *)
    public func dismissScreenStack() {
        // This will dismiss current screen and all screens pushed onto the current NavigationStack
        // .push, .sheet, .push, .push, .push, .sheet, .push
        
        var screensToDismiss: [AnyRoute] = []
        var didFindCurrentScreen: Bool = false
        var newRootScreen: AnyRoute? = currentRouteArray.first
        
        // Find all screens on current stack that are ahead of current screen that are .push & isPresented
        for route in currentRouteArray.filter({ $0.isPresented }).reversed() {
            if route.segue == .push {
                screensToDismiss.append(route)
            }
            
            if route.id == self.route.id {
                didFindCurrentScreen = true
            }
            
            // Stop when you find a sheet/fullScreenCover
            if route.segue != .push {
                
                // newRootScreen is the first screen before currentScreen that is not .push
                if didFindCurrentScreen {
                    newRootScreen = route
                    break
                    
                // push must be on a lower stack, reset screensToDismiss
                } else {
                    screensToDismiss = []
                }
            }
        }
        
        guard didFindCurrentScreen, newRootScreen != nil else {
            #if DEBUG
            print(printPrefix + "Failed to dismiss screens screenStack. Could not find user's active screens.")
            #endif
            return
        }
        
        for route in screensToDismiss {
            route.onDismiss?()
            updateRouteIsPresented(route: route, isPresented: false)
        }
        
        // Remove routes (not needed?)
        //removeRoutingFlowsAfterRoute(newRootScreen)

        // Reset screens to match NavigationStack path
        screens = []
        screenStack = []
    }

}

// MARK: Alerts

extension RouterViewInternal {
    
    public func showAlert<T:View>(_ option: DialogOption, title: String, subtitle: String?, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]?) {
        guard self.alert == nil else {
            dismissAlert()
            return
        }
        
        self.alertOption = option
        self.alert = AnyAlert(title: title, subtitle: subtitle, buttons: alert(), buttonsiOS13: buttonsiOS13)
    }
    
    public func dismissAlert() {
        self.alert = nil
    }

}

// MARK: Modal

extension RouterViewInternal {
    
    public func showModal<T:View>(
        id: String? = nil,
        transition: AnyTransition,
        animation: Animation,
        alignment: Alignment,
        backgroundColor: Color?,
        dismissOnBackgroundTap: Bool,
        ignoreSafeArea: Bool,
        @ViewBuilder destination: @escaping () -> T) {

            let config = ModalConfiguration(transition: transition, animation: animation, alignment: alignment, backgroundColor: backgroundColor, dismissOnBackgroundTap: dismissOnBackgroundTap, ignoreSafeArea: ignoreSafeArea)
            let dest = AnyDestination(destination())
            
            self.modals.append(AnyModalWithDestination(id: id ?? UUID().uuidString, configuration: config, destination: dest))
        }
    
    public func dismissModal(id: String? = nil) {
        if let id {
            if let index = modals.lastIndex(where: { $0.id == id && !$0.didDismiss }) {
                modals[index].dismiss()
                
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 25_000)
                    modals.remove(at: index)
                }
            }
        } else {
            if let index = modals.lastIndex(where: { !$0.didDismiss }) {
                modals[index].dismiss()
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 25_000)
                    modals.remove(at: index)
                }
            }
        }
    }

    public func dismissAllModals() {
        // Dismiss all modals
        for (index, modal) in modals.enumerated() {
            // Don't dismiss "origin" view
            if index > 0 && !modal.didDismiss {
                modals[index].dismiss()
            }
        }
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 25_000)
            
            // Reset array to "origin"
            modals = [modals.first!]
        }
    }
}
