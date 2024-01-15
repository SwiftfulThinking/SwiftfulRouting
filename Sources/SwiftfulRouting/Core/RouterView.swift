//
//  RouterView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

/// RouterView adds modifiers for segues, alerts, and modals. If you are already within a Navigation heirarchy, set addNavigationView = false.
public struct RouterView<T:View>: View, Router {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL

    let addNavigationView: Bool
    let content: (AnyRouter) -> T
 
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
    @State private var alertOption: AlertOption = .alert
    @State private var alert: AnyAlert? = nil
    
    // Modals
    @State private var modalConfiguration: ModalConfiguration = .default
    @State private var modal: AnyDestination? = nil
    
    // Need a Binding to Routes across RouterViews
    // Need to initialize the array
    
    public init(addNavigationView: Bool = true, screens: (Binding<[AnyDestination]>)? = nil, route: AnyRoute? = nil, routes: Binding<[[AnyRoute]]>? = nil, environmentRouter: Router? = nil, @ViewBuilder content: @escaping (AnyRouter) -> T) {
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
    
    public var body: some View {
        NavigationViewIfNeeded(addNavigationView: addNavigationView, segueOption: segueOption, onDismiss: onDismissOfPush, onDismissLastPush: onDismissOfLastPush, screens: $screens) {
            content(AnyRouter(object: self))
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
        }
        .showingAlert(option: alertOption, item: $alert)
        .showingModal(configuration: modalConfiguration, item: $modal)
    }
    
    private var useRoutesNotRootRoutes: Bool {
        !routes.isEmpty
    }
    
    private func updateRouteIsPresented(route: AnyRoute, isPresented: Bool) {
        
        func setRouteIsPresented(array: inout [[AnyRoute]]) {
            for (setIndex, set) in array.enumerated() {
                for (index, someRoute) in set.enumerated() {
                    if someRoute.id == route.id {
                        array[setIndex][index].updateIsPresented(to: isPresented)
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
        
//        if !routes.isEmpty {
//            for (setIndex, set) in routes.enumerated() {
//                for (index, someRoute) in set.enumerated() {
//                    if someRoute.id == route.id {
//                        routes[setIndex][index].updateIsPresented(to: isPresented)
//                        return
//                    }
//                }
//            }
//        } else {
//            for (setIndex, set) in rootRoutes.enumerated() {
//                for (index, someRoute) in set.enumerated() {
//                    if someRoute.id == route.id {
//                        rootRoutes[setIndex][index].updateIsPresented(to: isPresented)
//                        return
//                    }
//                }
//            }
//        }
    }
    
    private func onDismissOfLastPush() {
        // This is called within the NavigationStack's root Router, but is dismissing the last screen in the stack
        print("onDismissOfLastPush")

        let routes = (!routes.isEmpty ? routes : rootRoutes)
        
        if let screenToDismiss = routes.last?.last(where: { $0.isPresented }) {
            screenToDismiss.onDismiss?()
            updateRouteIsPresented(route: screenToDismiss, isPresented: false)
            
            let newRootScreen: AnyRoute = routes.flatMap({ $0 }).firstBefore(screenToDismiss) ?? screenToDismiss
            removeRoutes(route: newRootScreen)
            
        }
        
        screens.removeLast()
    }
    
    private func onDismissOfPush() {
        // This is called within the Router of the last screen in $screens, and is dismissing this screen
        print("ON DISMISS OF PUSH")

        let routes = (!routes.isEmpty ? routes : rootRoutes)
        
        // allRoutesInFrontOfCurrent should always be 0?
        let allRoutesInFrontOfCurrent = routes.flatMap({ $0 }).allAfter(route) ?? []
        let routesToDismiss = [self.route] + allRoutesInFrontOfCurrent
        for route in routesToDismiss.reversed() {
            route.onDismiss?()
            updateRouteIsPresented(route: route, isPresented: false)
        }
        
        let newRootScreen: AnyRoute = routes.flatMap({ $0 }).firstBefore(self.route) ?? self.route

        
        removeRoutes(route: newRootScreen)
    }
    
    private func onDismissOfSheet() {
        print("ON DISMISS OF SHEET")
        
        let routes = (!routes.isEmpty ? routes : rootRoutes)
        
        var allRoutesInFrontOfCurrent = routes.flatMap({ $0 }).allAfter(route)?.filter({ $0.isPresented }) ?? []
        
        if isResizableSheet {
            allRoutesInFrontOfCurrent.insert(route, at: 0)
        }
        
        for route in allRoutesInFrontOfCurrent.reversed() {
            route.onDismiss?()
            updateRouteIsPresented(route: route, isPresented: false)
        }
        
        removeRoutes(route: self.route)
    }
    
    private func setEnvironmentRouterIfNeeded() {
        // If this is a new environnent (ie. .sheet or .fullScreenCover) then no previous environmentRouter will be passed in
        // Therefore, this is the start of a new environment and this router will be the environmentRouter
        // The first screen should not have one
        if environmentRouter == nil {
            environmentRouter = self
        }
    }
    
    /// Show a flow of screens, segueing to the first route immediately. The following routes can be accessed via 'showNextScreen()'.
    public func showScreens(_ newRoutes: [AnyRoute]) {
        guard let route = newRoutes.first else {
            assertionFailure("SwiftfulRouting: No routes found.")
            return
        }
        
        appendRoutes(newRoutes: newRoutes)
        
        let destination = { router in
            AnyView(route.destination(router))
        }
        
        showScreen(route, destination: destination)
    }
    
    public func dismissEnvironment() {
        if let environmentRouter {
            environmentRouter.dismissScreen()
        } else {
            dismissScreen()
        }
    }
    
    private enum RoutableError: LocalizedError {
        case noNextScreenSet
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
    
    private func removeRoutes(route: AnyRoute) {
        // Remove all flows after current
        if !routes.isEmpty {
            routes.removeArraysAfter(arrayThatIncludesId: route.id)
        } else {
            rootRoutes.removeArraysAfter(arrayThatIncludesId: route.id)
        }
    }
    
    var routeBinding: Binding<[[AnyRoute]]> {
        if !routes.isEmpty {
            return $routes
        }
        return $rootRoutes
    }
    
    func appendRoutes(newRoutes: [AnyRoute]) {
        if !routes.isEmpty {
            self.routes.append(newRoutes)
        } else {
            self.rootRoutes.append(newRoutes)
        }
    }
    
    // if isEnvironmentRouter & screens no longer includes this screen, then environment did dismiss?
    
    private func showScreen<V:View>(_ route: AnyRoute, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        self.segueOption = route.segue

        if route.segue != .push {
            // Add new Navigation
            // Sheet and FullScreenCover enter new Environments and require a new Navigation to be added, and don't need an environmentRouter because they will host the environment.
            self.sheetDetents = [.large]
            self.sheetSelectionEnabled = false
            self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, route: route, routes: routeBinding, environmentRouter: nil, content: destination), onDismiss: nil))
        } else {
            // Using existing Navigation
            // Push continues in the existing Environment and uses the existing Navigation
            
            
            // iOS 16 uses NavigationStack and can push additional views onto an existing view stack
            if #available(iOS 16, *) {
                if screenStack.isEmpty {
                    // We are in the root Router and should start building on $screens
                    self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screens, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
                } else {
                    // We are not in the root Router and should continue off of $screenStack
                    self.screenStack.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screenStack, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
                }
                
            // iOS 14/15 uses NavigationView and can only push 1 view at a time
            } else {
                // Push a new screen and don't pass view stack to child view (screens == nil)
                self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: nil, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
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
            
            let view = AnyDestination(RouterView<AnyView>(addNavigationView: false, screens: bindingStack, route: route, routes: routeBinding, environmentRouter: environmentRouter, content: { router in
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
        
        self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, route: route, routes: routeBinding, environmentRouter: nil, content: destination), onDismiss: nil))
    }
    
    public func dismissScreen() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    @available(iOS 16, *)
    public func dismissScreenStack() {
        
        // This will dismiss current screen and all pushes on curent NavigationStack
       
        // Find all screens that will be dismissed
        
        let allRoutes = !routes.isEmpty ? routes : rootRoutes
        var didFindCurrentScreen: Bool = false
        var newRootScreen: AnyRoute? = allRoutes.first?.first
        
        for route in allRoutes.flatMap({ $0 }).reversed() {
            if route.id == self.route.id {
                didFindCurrentScreen = true
            }
            
            // Stop when you find a sheet/fullScreenCover
            if route.segue != .push {
                newRootScreen = route
                break
            }
            
            if didFindCurrentScreen {
                route.onDismiss?()
            }
        }
        
        if let newRootScreen {
            removeRoutes(route: newRootScreen)
        }
        
        self.screens = []
        self.screenStack = []

    }
    
    public func showAlert<T:View>(_ option: AlertOption, title: String, subtitle: String?, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]?) {
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
    
    public func showModal<T:View>(
        transition: AnyTransition,
        animation: Animation,
        alignment: Alignment,
        backgroundColor: Color?,
        backgroundEffect: BackgroundEffect?,
        useDeviceBounds: Bool,
        @ViewBuilder destination: @escaping () -> T) {
            guard self.modal == nil else {
                dismissModal()
                return
            }
            
            self.modalConfiguration = ModalConfiguration(transition: transition, animation: animation, alignment: alignment, backgroundColor: backgroundColor, backgroundEffect: backgroundEffect, useDeviceBounds: useDeviceBounds)
            self.modal = AnyDestination(destination())
        }
    
    public func dismissModal() {
        self.modal = nil
    }
    
    public func showSafari(_ url: @escaping () -> URL) {
        openURL(url())
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

    @ViewBuilder func showingAlert(option: AlertOption, item: Binding<AnyAlert?>) -> some View {
        self
            .modifier(ConfirmationDialogViewModifier(option: option, item: item))
            .modifier(AlertViewModifier(option: option, item: item))
    }
    
    func showingModal(configuration: ModalConfiguration, item: Binding<AnyDestination?>) -> some View {
        modifier(ModalViewModifier(configuration: configuration, item: item))
    }
    
}
