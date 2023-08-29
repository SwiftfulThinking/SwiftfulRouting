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
 
    // Segues
    @State private var segueOption: SegueOption = .push
    @State public var screens: [AnyDestination] = []
    
    // Binding to view stack from previous RouterViews
    @Binding private var screenStack: [AnyDestination]
    @State private var screenStackCount: Int = 0

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
    
    // Popover
    @State private var popoverAnchor: PopoverAttachmentAnchor = .point(.bottom)
    @State private var popover: AnyDestination? = nil
    
    public init(addNavigationView: Bool = true, screens: (Binding<[AnyDestination]>)? = nil, @ViewBuilder content: @escaping (AnyRouter) -> T) {
        self.addNavigationView = addNavigationView
        self._screenStack = screens ?? .constant([])
        self._screenStackCount = State(wrappedValue: (screens?.wrappedValue.count ?? 0))
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
                    showDragIndicator: showDragIndicator)
                .showingPopover(anchor: popoverAnchor, item: $popover)
                .onChange(of: presentationMode.wrappedValue.isPresented) { isPresented in
//                    if !isPresented {
//                        popover = nil
//                    }
                    print("IS PRESENTED")
                }
        }
        .showingAlert(option: alertOption, item: $alert)
        .showingModal(configuration: modalConfiguration, item: $modal)
    }
    
    public func showScreen<V:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        self.segueOption = option
        self.popover = nil

        if option != .push {
            // Add new Navigation
            // Sheet and FullScreenCover enter new Environments and require a new Navigation to be added.
            self.sheetDetents = [.large]
            self.sheetSelectionEnabled = false
            self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, content: destination)))
        } else {
            // Using existing Navigation
            // Push continues in the existing Environment and uses the existing Navigation
            
            
            // iOS 16 uses NavigationStack and can push additional views onto an existing view stack
            if #available(iOS 16, *) {
                if screenStack.isEmpty {
                    // We are in the root Router and should start building on $screens
                    self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screens, content: destination)))
                } else {
                    // We are not in the root Router and should continue off of $screenStack
                    self.screenStack.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screenStack, content: destination)))
                }
                
            // iOS 14/15 uses NavigationView and can only push 1 view at a time
            } else {
                // Push a new screen and don't pass view stack to child view (screens == nil)
                self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: nil, content: destination)))
            }
        }
    }
    
    @available(iOS 16, *)
    public func pushScreens(destinations: [(AnyRouter) -> any View]) {
        // iOS 16 supports NavigationStack, which can push a stack of views and increment an existing view stack
        self.segueOption = .push
        
        // Loop on injected destinations and add them to localStack
        // If screenStack.isEmpty, we are in the root Router and should start building on $screens
        // Else, we are not in the root Router and should continue off of $screenStack

        var localStack: [AnyDestination] = []
        let bindingStack = screenStack.isEmpty ? $screens : $screenStack

        destinations.forEach { destination in
            let view = AnyDestination(RouterView<AnyView>(addNavigationView: false, screens: bindingStack, content: { router in
                AnyView(destination(router))
            }))
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
        
        self.screens.append(AnyDestination(RouterView<V>(addNavigationView: true, screens: nil, content: destination)))
    }
    
    @available(iOS 16.4, *)
    public func showPopover<V:View>(anchor: PopoverAttachmentAnchor, @ViewBuilder destination: @escaping () -> V) {
        self.popoverAnchor = anchor
        self.popover = AnyDestination(destination())
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

    func showingAlert(option: AlertOption, item: Binding<AnyAlert?>) -> some View {
        self
            .modifier(ConfirmationDialogViewModifier(option: option, item: item))
            .modifier(AlertViewModifier(option: option, item: item))
    }
    
    func showingModal(configuration: ModalConfiguration, item: Binding<AnyDestination?>) -> some View {
        modifier(ModalViewModifier(configuration: configuration, item: item))
    }
   
    @ViewBuilder func showingPopover(anchor: PopoverAttachmentAnchor, item: Binding<AnyDestination?>) -> some View {
        if #available(iOS 16.4, *) {
            modifier(PopoverViewModifier(anchor: anchor, screen: item))
        } else {
            self
        }
    }
}
