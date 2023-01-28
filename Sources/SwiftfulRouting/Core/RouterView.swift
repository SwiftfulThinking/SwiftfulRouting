//
//  SwiftUIView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

public protocol Router {
    func showScreen<V:View>(
        _ option: SegueOption,
        @ViewBuilder destination: @escaping (AnyRouter) -> V)
    
    func dismissScreen()
    
    func showAlert<V:View>(
        _ option: AlertOption,
        title: String,
        subtitle: String?,
        @ViewBuilder alert: @escaping () -> V)
    
    func dismissAlert()
    
    func showModal<V:View>(
        transition: AnyTransition,
        animation: Animation,
        alignment: Alignment,
        backgroundColor: Color?,
        useDeviceBounds: Bool,
        @ViewBuilder destination: @escaping () -> V)
    
    func dismissModal()
}

public struct AnyRouter: Router {
    let object: any Router
    
    public func showScreen<T>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> T) where T : View {
        object.showScreen(option, destination: destination)
    }
    
    public func dismissScreen() {
        object.dismissScreen()
    }
    
    public func showAlert<T>(_ option: AlertOption, title: String, subtitle: String? = nil, @ViewBuilder alert: @escaping () -> T) where T : View {
        object.showAlert(option, title: title, subtitle: subtitle, alert: alert)
    }
    
    public func dismissAlert() {
        object.dismissAlert()
    }
    
    public func showModal<T>(
        transition: AnyTransition = .move(edge: .bottom),
        animation: Animation = .easeInOut,
        alignment: Alignment = .center,
        backgroundColor: Color? = nil,
        useDeviceBounds: Bool = true,
        @ViewBuilder destination: @escaping () -> T) where T : View {
        object.showModal(transition: transition, animation: animation, alignment: alignment, backgroundColor: backgroundColor, useDeviceBounds: useDeviceBounds, destination: destination)
    }
    
    public func dismissModal() {
        object.dismissModal()
    }
}

/// RouterView adds modifiers for segues, alerts, and modals. Use the escaping Router to perform actions. If you are already within a Navigation heirarchy, set addNavigationView = false.
public struct RouterView<T:View>: View, Router {
    
    @Environment(\.presentationMode) var presentationMode
    let addNavigationView: Bool

    @State private var segueOption: SegueOption = .push
    @State private var screens: [AnyDestination] = []
    @Binding private var screenStack: [AnyDestination] // Binding to view stack from previous RouterViews

    @State private var alertOption: AlertOption = .alert
    @State private var alert: AnyAlert? = nil

    @State private var modalConfiguration: ModalConfiguration = .default
    @State private var modal: AnyDestination? = nil
    
    let content: (AnyRouter) -> T
    
    public init(addNavigationView: Bool = true, screens: (Binding<[AnyDestination]>)? = nil, @ViewBuilder content: @escaping (AnyRouter) -> T) {
        self.addNavigationView = addNavigationView
        self._screenStack = screens ?? .constant([])
        self.content = content
    }
    
    public var body: some View {
        OptionalNavigationView(addNavigationView: addNavigationView, segueOption: segueOption, screens: $screens) {
            content(AnyRouter(object: self))
                .showingScreen(option: segueOption, items: $screens)
        }
        .showingAlert(option: alertOption, item: $alert)
        .showingModal(configuration: modalConfiguration, item: $modal)
    }
    
    public func showScreen<V:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> V) {
        self.segueOption = option

        // Push maintains the current Navigation heirarchy
        // Sheet and FullScreenCover enter new Environments and require a new Navigation to be added.
        let shouldAddNavigationView = option != .push

        if shouldAddNavigationView {
            // Add Navigation, reset view stack
            self.screens.append(AnyDestination(RouterView<V>(addNavigationView: shouldAddNavigationView, screens: nil, content: destination)))
        } else {
            // Using existing Navigation
            
            // If start of a new stack
            if screenStack.isEmpty {
                // Start view stack
                self.screens.append(AnyDestination(RouterView<V>(addNavigationView: shouldAddNavigationView, screens: $screens, content: destination)))
                print("NEW STACK!")
            } else {
                // Increment view stack
                self.screenStack.append(AnyDestination(RouterView<V>(addNavigationView: shouldAddNavigationView, screens: $screenStack, content: destination)))
                print("INCREMENTING!")
            }
        }
        
        
        //
//        guard self.screens.isEmpty else {
//            print("Cannot segue because a destination has already been set in this router.")
//            return
//        }
//
//        self.screens = [
//            AnyDestination(RouterView<V>(addNavigationView: shouldAddNavigationView, screens: $screens, content: destination))
//        ]
    }
    
    public func dismissScreen() {
        self.presentationMode.wrappedValue.dismiss()
    }
    
    public func showAlert<T:View>(_ option: AlertOption, title: String, subtitle: String? = nil, @ViewBuilder alert: @escaping () -> T) {
        guard self.alert == nil else {
            dismissAlert()
            return
        }
        
        self.alertOption = option
        self.alert = AnyAlert(title: title, subtitle: subtitle, buttons: alert())
    }
    
    public func dismissAlert() {
        self.alert = nil
    }
    
    public func showModal<T:View>(
        transition: AnyTransition = .move(edge: .bottom),
        animation: Animation = .easeInOut,
        alignment: Alignment = .center,
        backgroundColor: Color? = nil,
        useDeviceBounds: Bool = true,
        @ViewBuilder destination: @escaping () -> T) {
            guard self.modal == nil else {
                dismissModal()
                return
            }
            
            self.modalConfiguration = ModalConfiguration(transition: transition, animation: animation, alignment: alignment, backgroundColor: backgroundColor, useDeviceBounds: useDeviceBounds)
            self.modal = AnyDestination(destination())
        }
    
    public func dismissModal() {
        self.modal = nil
    }
}

struct OptionalNavigationView<Content:View>: View {
    
    let addNavigationView: Bool
    let segueOption: SegueOption
    @Binding var screens: [AnyDestination]
    @ViewBuilder var content: Content
    
    @ViewBuilder var body: some View {
        if addNavigationView {
            if #available(iOS 16.0, *) {
                let path = Binding(if: segueOption, is: .push, value: $screens)
                
                NavigationStack(path: path) {
                    content
                }
            } else {
                NavigationView {
                    content
                }
            }
        } else {
            content
        }
    }
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
//        RouterView(addNavigationView: true) { router in
            Text("Hi")
                .onTapGesture {
//                    router.showScreen(.push) { router in
//                        Text("Hello, world")
//                    }
                }
//        }
    }
}

extension View {
    
    @ViewBuilder func showingScreen(option: SegueOption, items: Binding<[AnyDestination]>) -> some View {
        if #available(iOS 14, *) {
            self
                .modifier(NavigationLinkViewModifier(option: option, items: items))
                .modifier(SheetViewModifier(option: option, items: items))
                .modifier(FullScreenCoverViewModifier(option: option, items: items))
        } else {
            self
                .modifier(NavigationLinkViewModifier(option: option, items: items))
                .modifier(SheetViewModifier(option: option, items: items))
        }
    }

    @ViewBuilder func showingAlert(option: AlertOption, item: Binding<AnyAlert?>) -> some View {
        if #available(iOS 15, *) {
            if option == .confirmationDialog {
                modifier(ConfirmationDialogViewModifier(item: item))
            } else {
                modifier(AlertViewModifier(item: item))
            }
        } else {
            self
        }
    }
    
    @ViewBuilder func showingModal(configuration: ModalConfiguration, item: Binding<AnyDestination?>) -> some View {
        if #available(iOS 14, *) {
            modifier(ModalViewModifier(configuration: configuration, item: item))
        } else {
            self
        }
    }
}
