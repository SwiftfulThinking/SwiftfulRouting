//
//  SwiftUIView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

/// RouterView adds modifiers for segues, alerts, and modals. Use the escaping Router to perform actions. If you are already within a Navigation heirarchy, set addNavigationView = false.
public struct RouterView<T:View>: View {
    
    @Environment(\.presentationMode) var presentationMode
    let addNavigationView: Bool

    @State private(set) var segueOption: SegueOption = .push
    @State var screens: [AnyDestination] = []

    @State private(set) var alertOption: AlertOption = .alert
    @State var alert: AnyAlert? = nil

    @State private(set) var modalConfiguration: ModalConfiguration = .default
    @State var modal: AnyDestination? = nil
    
    let content: (RouterView) -> T
    
    public init(addNavigationView: Bool, @ViewBuilder content: @escaping (RouterView) -> T) {
        self.addNavigationView = addNavigationView
        self.content = content
    }
    
    public var body: some View {
        OptionalNavigationView(addNavigationView: addNavigationView, segueOption: segueOption, screens: $screens) {
            content(self)
                .showingScreen(option: segueOption, items: $screens)
        }
        .showingAlert(option: alertOption, item: $alert)
        .showingModal(configuration: modalConfiguration, item: $modal)
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
