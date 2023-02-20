//
//  RouterView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

/// RouterView adds modifiers for segues, alerts, and modals. Use the escaping Router to perform actions. If you are already within a Navigation heirarchy, set addNavigationView = false.

public struct RouterView<T:View>: View, Router {
    
    @Environment(\.presentationMode) var presentationMode
    let addNavigationView: Bool
    let content: (AnyRouter) -> T
 
    // Segues
    @State private var segueOption: SegueOption = .push
    @State public var screens: [AnyDestination] = []
    
    // Binding to view stack from previous RouterViews
    @Binding private var screenStack: [AnyDestination]
    @State private var screenStackCount: Int

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
                .onChangeIfiOS15(of: presentationMode.wrappedValue.isPresented, perform: dropLastScreenFromStackForiOS16IfNeeded)
        }
        .showingAlert(option: alertOption, item: $alert)
        .showingModal(configuration: modalConfiguration, item: $modal)
    }
    
    public func showScreen<V:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        self.segueOption = option

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
                    print("append a")
                    self.screens.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screens, content: destination)))
                } else {
                    print("append b")
                    // We are not in the root Router and should continue off of $screenStack
                    self.screenStack.append(AnyDestination(RouterView<V>(addNavigationView: false, screens: $screenStack, content: destination)))
                }
                
            // iOS 14/15 uses NavigationView and can only push 1 view at a time
            } else {
                print("append c")
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
    
    public func dismissScreen() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    @available(iOS 16, *)
    public func popToRoot() {
        self.screens = []
        self.screenStack = []
    }
    
    private func dropLastScreenFromStackForiOS16IfNeeded(isPresented: Bool) {
        // iOS 16 supports screenStack, however,
        // if user dismisses the screen using .dismissScreen or environment modes, then the screen will dismiss without removing last item from screenStack
        // which then leads to the next push appearing on top of existing (incorrect) stack
        
        // This is called when isPresented changes, and should only removeLast if isPresented = false
        // This is 
        
        print("ssc: \(screenStack.count) :: \(screenStackCount)")
        if !isPresented && (screenStack.count + 1) == screenStackCount {
            print("remove a :: \(screenStack.first?.id ?? "n/a")")
            screenStack.removeLast()
        }
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
