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
    @State private var previousScreens: [AnyDestination] = []
    
    /// routes are all routes set on heirarchy, included ones that are in front of current screen
    @State private var routes: [[AnyRoute]]
    @State private var environmentRouter: Router?
    @State private var onDismiss: (() -> Void)? = nil

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
        }
        self._environmentRouter = State(wrappedValue: environmentRouter)
        self.content = content

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
                    showDragIndicator: showDragIndicator,
                    onDismiss: {
//                        print("WE KNOW IT DISMISSED: \(route.id)")
//                        onDismiss?()
                    }
                )
                .onFirstAppear(perform: setEnvironmentRouterIfNeeded)
        }
        .showingAlert(option: alertOption, item: $alert)
        .showingModal(configuration: modalConfiguration, item: $modal)
        .onChange(of: screens, perform: { newValue in
//            print("SCREENS COUNT CHANGED: \(newValue)")
            // If new value doesn't have a screen from previous value, it is dismissed
            for screen in previousScreens {
                if !newValue.contains(screen) {
//                    print("THIS ONE IS GONE")
                    screen.onDismiss?()
                }
            }
            
            previousScreens = newValue
        })
    }
    
    private func setEnvironmentRouterIfNeeded() {
        // If this is a new environnent (ie. .sheet or .fullScreenCover) then no previous environmentRouter will be passed in
        // Therefore, this is the start of a new environment and this router will be the environmentRouter
        // The first screen should not have one
        if environmentRouter == nil {
            environmentRouter = self
        }
    }
    
    // onDidDismissFlow: (@MainActor () -> Void)? = nil
    /// Show a flow of screens, segueing to the first route immediately. The following routes can be accessed via 'showNextScreen()'.
    public func showScreens(_ newRoutes: [AnyRoute]) {
        guard let route = newRoutes.first else {
            assertionFailure("SwiftfulRouting: No routes found.")
            return
        }
        
        routes.append(newRoutes)
        
        let destination = { router in
            AnyView(route.destination(router))
        }
        
        showScreen(route, destination: destination, onDismiss: route.onDismiss)
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
    
    // onDismiss: (() -> Void)? = nil
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
        
        showScreen(nextRoute, destination: destination, onDismiss: nextRoute.onDismiss)
    }
    
    private func removeRoutes(route: AnyRoute) {
        // After segueing, remove that flow from local routes
        // Loop backwards, if have not yet found the current flow...
        // it's a future flow or the current flow and should be removed now
        for (index, item) in routes.enumerated().reversed() {
            routes.remove(at: index)
            
            if item.contains(where: { $0.id == route.id }) {
                return
            }
        }
    }
    
    // if isEnvironmentRouter & screens no longer includes this screen, then environment did dismiss?
    
    private func showScreen<V:View>(_ route: AnyRoute, @ViewBuilder destination: @escaping (AnyRouter) -> V, onDismiss: (() -> Void)?) {
        self.segueOption = route.segue
        self.onDismiss = onDismiss

        if route.segue != .push {
            // Add new Navigation
            // Sheet and FullScreenCover enter new Environments and require a new Navigation to be added, and don't need an environmentRouter because they will host the environment.
            self.sheetDetents = [.large]
            self.sheetSelectionEnabled = false
            self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, route: route, routes: routes, environmentRouter: nil, content: destination), onDismiss: route.onDismiss))
        } else {
            // Using existing Navigation
            // Push continues in the existing Environment and uses the existing Navigation
            
            
            // iOS 16 uses NavigationStack and can push additional views onto an existing view stack
            if #available(iOS 16, *) {
                if screenStack.isEmpty {
                    // We are in the root Router and should start building on $screens
                    self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screens, route: route, routes: routes, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
                } else {
                    // We are not in the root Router and should continue off of $screenStack
                    self.screenStack.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screenStack, route: route, routes: routes, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
                }
                
            // iOS 14/15 uses NavigationView and can only push 1 view at a time
            } else {
                // Push a new screen and don't pass view stack to child view (screens == nil)
                self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: nil, route: route, routes: routes, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
            }
        }
        
        removeRoutes(route: route)
    }
    
    @available(iOS 16, *)
    public func pushScreenStack(destinations: [(AnyRouter) -> any View]) {
        // iOS 16 supports NavigationStack, which can push a stack of views and increment an existing view stack
        self.segueOption = .push
        
        // Loop on injected destinations and add them to localStack
        // If screenStack.isEmpty, we are in the root Router and should start building on $screens
        // Else, we are not in the root Router and should continue off of $screenStack

        var localStack: [AnyDestination] = []
        let bindingStack = screenStack.isEmpty ? $screens : $screenStack
        var localRoutes: [AnyRoute] = []

        destinations.forEach { destination in
            let route = AnyRoute(.push, destination: destination)
            localRoutes.append(route)
            
            let allRoutes: [[AnyRoute]] = routes + [localRoutes]
            
            let view = AnyDestination(RouterView<AnyView>(addNavigationView: false, screens: bindingStack, route: route, routes: allRoutes, environmentRouter: environmentRouter, content: { router in
                AnyView(destination(router))
            }), onDismiss: route.onDismiss)
            localStack.append(view)
        }

        if screenStack.isEmpty {
            self.screens.append(contentsOf: localStack)
        } else {
            self.screenStack.append(contentsOf: localStack)
        }
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
        
        self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, route: route, routes: routes, environmentRouter: environmentRouter, content: destination), onDismiss: route.onDismiss))
    }
    
    public func dismissScreen() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    @available(iOS 16, *)
    public func dismissScreenStack() {
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
        onDismiss: @escaping () -> Void
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
