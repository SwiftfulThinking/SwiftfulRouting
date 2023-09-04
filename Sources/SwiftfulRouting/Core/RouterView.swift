//
//  RouterView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

extension View {
    func onFirstAppear(perform action: @escaping () -> Void) -> some View {
        self.modifier(OnFirstAppearModifier(action: action))
    }
}

struct OnFirstAppearModifier: ViewModifier {
    let action: @MainActor () -> Void
    @State private var isFirstAppear = true
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                if isFirstAppear {
                    action()
                    isFirstAppear = false
                }
            }
    }
}

/// RouterView adds modifiers for segues, alerts, and modals. Use the escaping Router to perform actions. If you are already within a Navigation heirarchy, set addNavigationView = false.

public struct RouterView<T:View>: View, Router {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) var openURL

    let addNavigationView: Bool
    let content: (AnyRouter) -> T
 
    // Routable methods
    @State private var route: AnyRoute

    // Segues
    @State private var segueOption: SegueOption = .push
    @State public var screens: [AnyDestination] = []
    
    /// routes are all routes set on heirarchy, included ones that are in front of current screen
    @State private var routes: [[AnyRoute]]
    @State private var environmentRouter: Router?

    // Binding to view stack from previous RouterViews
    @Binding private var screenStack: [AnyDestination]

    // Configuration for resizable sheet on iOS 16+
    // TODO: Move resizable sheet modifiers into a struct "SheetConfiguration"
    @State private var sheetDetents: Set<PresentationDetentTransformable> = [.large]
    @State private var sheetSelection: Binding<PresentationDetentTransformable> = .constant(.large)
    @State private var sheetSelectionEnabled: Bool = false
    @State private var showDragIndicator: Bool = true

    // Alerts
    @State private var alertOption: AlertOption = .alert
    @State private var alert: AnyAlert? = nil
    
    // Modals
    @State private var modalConfiguration: ModalConfiguration = .default
    @State private var modal: AnyDestination? = nil
    
    public init(addNavigationView: Bool = true, screens: (Binding<[AnyDestination]>)? = nil, route: AnyRoute? = nil, routes: [[AnyRoute]]? = nil, environmentRouter: Router? = nil, @ViewBuilder content: @escaping (AnyRouter) -> T) {
        self.addNavigationView = addNavigationView
        self._screenStack = screens ?? .constant([])
        
        if let route {
            self._route = State(wrappedValue: route)
            self._routes = State(wrappedValue: routes ?? [])
        } else {
            let root = AnyRoute.root
            self._route = State(wrappedValue: root)
            self._routes = State(wrappedValue: [[root]])
            print("ROOT ID: \(root)")
        }
        self._environmentRouter = State(wrappedValue: environmentRouter)
        self.content = content
        
//        print("INIT ROUTE: \(route?.id ?? "n/a")")
//        print("INIT ROUTES: \(self.routes.map({ $0.id }))")
//        print("INIT ROUTES: \(self.routes.map({ $0.didSegue }))")
//        print("ON INIT W ROUTES: \(routes?.count ?? -999)")
//        print("STARTING ROUT: \(self.route.id)")

    }
    
    public var body: some View {
        NavigationViewIfNeeded(addNavigationView: addNavigationView, segueOption: segueOption, screens: $screens) {
            content(AnyRouter(object: self))
                .showingScreen(
                    option: segueOption,
                    screens: $screens,
                    screenStack: screenStack,
                    sheetDetents: sheetDetents,
                    sheetSelection: sheetSelection,
                    sheetSelectionEnabled: sheetSelectionEnabled,
                    showDragIndicator: showDragIndicator
                )
                .onFirstAppear(perform: setEnvironmentRouterIfNeeded)
        }
        .showingAlert(option: alertOption, item: $alert)
        .showingModal(configuration: modalConfiguration, item: $modal)
    }
    
    private func setEnvironmentRouterIfNeeded() {
        // If this is a new environnent (ie. .sheet or .fullScreenCover) then no previous environmentRouter will be passed in
        // Therefore, this is the start of a new environment and this router will be the environmentRouter
        // The first screen should not have one
        if environmentRouter == nil {
            environmentRouter = self
        }
    }
    
    /// Show any screen via Push (NavigationLink), Sheet, or FullScreenCover.
//    public func showScreen(_ route: AnyRoute) {
//        showScreens([route])
//    }
    
    // showNextScreen is only for showing next screen and should not be calleg when setting?
    
    
    /// Show a flow of screens, segueing to the first route immediately. The following routes can be accessed via 'showNextScreen()'.
    public func showScreens(_ newRoutes: [AnyRoute]) {
        print("HI NICK SHOW SCREENS: \(newRoutes.map({ $0.id }))")
        // Need to avoid duplicates herein
        // prioritize these new routes, so existing duplicates should be
        // 1 - purged
        // 2 - marked as seen
        //
        // always purge
        // always replace stack?
        // routes is actually flows and it's an array of arrays [[AnyRoute]]
        guard let route = newRoutes.first else {
            fatalError()
            return
        }

        // routes is current routes up to current point
        // plus newRoutes
        
//        var temp: [AnyRoute] = []
//
//        for item in routes {
//            temp.append(item)
//
//            if item.id == route.id {
//                break
//            }
//        }
//        temp.append(contentsOf: newRoutes)
        
        // back to flows, must always insert after current flow
        // goToNext should check if it's a new flow to go to
        // but do not expose that to the client
        //
//
//        routes = temp
        routes.append(newRoutes)
//        routes.insertAfter(newRoutes, after: route)

//        guard let firstRoute = routes.first else {
//            assertionFailure("There must be at least 1 route in parameter [Routes].")
//            return
//        }
                
        
        // should always segue to first screen in showScreens!
        // So it's not "show next" it's show this flow now
        
//        do {
//            try showNextScreen()
//        } catch {
//            print(error)
//        }
//        func nextScreen(id: String, router: AnyRouter) -> AnyView {
//            // We will mutate router below, so create a var copy
////            var router = router
//
//            // Keep track of current screen by id
//            guard let index = routes.firstIndex(where: { $0.id == id }) else {
//                return AnyView(Text("Error SwiftfulRouting AnyRouter.nextScreen index"))
//            }
//
//            let route = routes[index]
//
//            // Set environment router when seguing to new environment only
//            switch route.segue {
//            case .push:
//                break
//            case .sheet, .fullScreenCover, .sheetDetents:
//                environmentRouter = router
//            }

            // Action to dismiss the environment, if available
//            var dismissEnvironment: (() -> Void)?
//            if let environmentRouter {
//                dismissEnvironment = {
//                    environmentRouter.dismissScreen()
//                }
//            }
//
//            // Action to go to the next screen, if available
//            var goToNextScreen: (() -> Void)? = nil
//            if routes.indices.contains(index + 1) {
//                goToNextScreen = {
//                    let nextRoute = routes[index + 1]
//                    router.showScreen(nextRoute.segue) { childRouter in
//                        nextScreen(id: nextRoute.id, router: childRouter)
//                    }
//                }
//            }
            
            // Update router with new Routable actions
//            let delegate = RoutableDelegate(
//                goToNextScreen: goToNextScreen,
//                dismissEnvironment: dismissEnvironment
//            )
//            router.setRoutable(delegate: delegate)
            
            // Return the view with its updated router
//            return AnyView(route.destination(router))
//        }
        
//        showScreen(firstRoute) { router in
//            AnyView(firstRoute.destination(router))
//            nextScreen(id: firstRoute.id, router: router)
//        }
        
        
        showScreen(route) { router in
            AnyView(route.destination(router))
        }
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
        
        var next: AnyRoute? = nil
        
//        print("CURRENT ROUT: \(route.id)")
//        print("IDS: \(routes.map({ $0.id }))")
//        print("VALUES: \(routes.map({ $0.didSegue }))")
        
        guard let currentFlowIndex = routes.lastIndex(where: { flow in
            return flow.contains(where: { $0.id == route.id })
        }) else {
            throw RoutableError.noNextScreenSet
        }
        let currentFlow = routes[currentFlowIndex]
////
////        // If there is another route in this flow
        if let nextRoute = currentFlow.firstAfter(route, where: { !$0.didSegue }) {
            next = nextRoute

            // The start of next flow
        }
        // else {
//            let nextFlowIndex = currentFlowIndex + 1
//            if routes.indices.contains(nextFlowIndex) {
//                let nextFlow = routes[nextFlowIndex]
//                next = nextFlow.first
//            }
//        }
        
//        if let lastFlow = routes.last {
//            if let nextRoute
//        }
        
        
//        } else if let nextFlow = routes.firstAfter(currentFlow),
//           let nextRoute = currentFlow.firstAfter(route, where: { !$0.didSegue }) {
//            next = nextRoute
//        }
//
//        if
//            let currentFlow = routes.last(where: { flow in
//                return flow.contains(where: { $0.id == route.id })
//            }),
//            let nextRoute = currentFlow.firstAfter(route, where: { !$0.didSegue }) {
//            next = nextRoute
//        }

        
        
        
        print("FLOWS")
        print(route)
        print(routes)
        
//        if let nextRoute = routes.firstAfter(route, where: { !$0.didSegue }) {
//            print("FOUND NEXT: \(nextRoute)")
//            next = nextRoute
//        }
        
        guard let next else {
            throw RoutableError.noNextScreenSet
        }
//        print("CURRENT ROUTE: \(route.id ?? "idk")")
//        print("ON SHOW NEXT:: \(routes.count ?? -999)")
        print("SHOW NEXT SCREEN TRIGGERED")
        showScreen(next) { router in
            AnyView(next.destination(router))
        }
    }
    
    private func markRoutesAsSeen(route: AnyRoute) {
        // Marks every route in this flow (up until the next environment) as seen
//        var routesFinal: [AnyRoute] = []
//        var didFindEndOfCurrentFlow: Bool = false
        
        
        // remove all flows AFTER this one
//        if
//            let currentFlowIndex = routes.lastIndex(where: { flow in
//                return flow.contains(where: { $0.id == route.id })
//            }) {
//
//            for route in routes {
//
//            }
//        }
        
        // Loop backwards, if have not yet found the current flow,
        // It's a future flow and should be removed now
        
        for (index, item) in routes.enumerated().reversed() {
            print("REMOVING ROUTE::::: \(index) \(item)")
            routes.remove(at: index)
            
            if item.contains(where: { $0.id == route.id }) {
                print("DID FINISH REMOVING")
                return
            }
        }
        
//        if let currentIndex = routes.lastIndex(where: { $0.id == route.id }) {
//
//            for (index, element) in routes.enumerated() {
//                if index < currentIndex {
//                    // before current route shouldn't get updated herein
//                    routesFinal.append(element)
//                } else if index == currentIndex {
//                    // update this flow as seen
////                    var updated = element
////                    updated.setDidSegueToTrue()
////                    routesFinal.append(updated)
//                } else {
//                    // update every route after current route until the next environment
////                    switch element.segue {
////                    case .fullScreenCover, .sheet, .sheetDetents:
////                        didFindEndOfCurrentFlow = true
////                    case .push:
////                        break
////                    }
////
////                    if didFindEndOfCurrentFlow {
////                        // don't update the next flow
////                        routesFinal.append(element)
////                    } else {
////                        // update this flow as seen
//////                        var updated = element
//////                        updated.setDidSegueToTrue()
//////                        routesFinal.append(updated)
////                        print("DID UPDATED THIS FLOW: \(index) :: \(currentIndex)")
////                    }
//                }
//            }
//        }
//        print("SETTING NEW ROUTE FINAL: \(routesFinal.map({$0.didSegue }))")
//        routes = routesFinal
    }
    
    private func showScreen<V:View>(_ route: AnyRoute, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        self.segueOption = route.segue
        print("HERE IS MY NEW ROUTE: \(route.id)")
        
//        Task {
            // Remove route
            // the problem is I am updates routes data model and it's not populating
//            var localRoutes: [AnyRoute] = routes
//            if let index = routes.firstIndex(where: { $0.id == route.id }) {
//                var route = routes[index]
//                route.setDidSegueToTrue()
//                routes[index] = route
//                print("SET: \(route.id) to TRUEEEEE")
////                routes = []
////                try? await Task.sleep(nanoseconds: 1_000_000_000)
////                routes = localRoutes
////                try? await Task.sleep(nanoseconds: 1_000_000_000)
////                print(localRoutes[index])
//                print(route)
//                print(routes[index])
//                print("HERE")
//            }

            
//        }
        if route.segue != .push {
            // Add new Navigation
            // Sheet and FullScreenCover enter new Environments and require a new Navigation to be added, and don't need an environmentRouter because they will host the environment.
            self.sheetDetents = [.large]
            self.sheetSelectionEnabled = false
            self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, route: route, routes: routes, environmentRouter: nil, content: destination)))
        } else {
            // Using existing Navigation
            // Push continues in the existing Environment and uses the existing Navigation
            
            
            // iOS 16 uses NavigationStack and can push additional views onto an existing view stack
            if #available(iOS 16, *) {
                if screenStack.isEmpty {
                    // We are in the root Router and should start building on $screens
                    self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screens, route: route, routes: routes, environmentRouter: environmentRouter, content: destination)))
                } else {
                    // We are not in the root Router and should continue off of $screenStack
                    self.screenStack.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screenStack, route: route, routes: routes, environmentRouter: environmentRouter, content: destination)))
                }
                
            // iOS 14/15 uses NavigationView and can only push 1 view at a time
            } else {
                // Push a new screen and don't pass view stack to child view (screens == nil)
                self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: nil, route: route, routes: routes, environmentRouter: environmentRouter, content: destination)))
            }
        }
        
        markRoutesAsSeen(route: route)
    }
    
    @available(iOS 16, *)
    public func pushScreenStack(destinations: [(AnyRouter) -> any View]) {
        // iOS 16 supports NavigationStack, which can push a stack of views and increment an existing view stack
        self.segueOption = .push
        
        // Loop on injected destinations and add them to localStack
        // If screenStack.isEmpty, we are in the root Router and should start building on $screens
        // Else, we are not in the root Router and should continue off of $screenStack

        fatalError("FIX ME LATER")
//        var localStack: [AnyDestination] = []
//        let bindingStack = screenStack.isEmpty ? $screens : $screenStack
//
//        destinations.forEach { destination in
//            let view = AnyDestination(RouterView<AnyView>(addNavigationView: false, screens: bindingStack, content: { router in
//                AnyView(destination(router))
//            }))
//            localStack.append(view)
//        }
//
//        if screenStack.isEmpty {
//            self.screens.append(contentsOf: localStack)
//        } else {
//            self.screenStack.append(contentsOf: localStack)
//        }
    }
    
    @available(iOS 16, *)
    public func showResizableSheet<V:View>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool = true, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        self.segueOption = .sheet
        self.sheetDetents = sheetDetents
        self.showDragIndicator = showDragIndicator

        // If selection == nil, then need to avoid using sheetSelection modifier
        if let selection {
            self.sheetSelection = selection
            self.sheetSelectionEnabled = true
        } else {
            self.sheetSelectionEnabled = false
        }
        
        fatalError()
//        self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, content: destination)))
    }
    
    public func dismissScreen() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    @available(iOS 16, *)
    public func popToRoot() {
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
        showDragIndicator: Bool) -> some View {
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
                        showDragIndicator: showDragIndicator
                    ))
                    .modifier(FullScreenCoverViewModifier(
                        option: option,
                        screens: screens
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
                        showDragIndicator: showDragIndicator
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
    
    @ViewBuilder func onChangeIfiOS15<E:Equatable>(of value: E, perform: @escaping (E) -> Void) -> some View {
        if #available(iOS 15, *) {
            self
                .onChange(of: value, perform: perform)
        } else {
            self
        }
    }
}
