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
    @StateObject private var router = Router()
    let addNavigationView: Bool
    let content: (Router) -> T
    
    public init(addNavigationView: Bool = true, @ViewBuilder content: @escaping (Router) -> T) {
        self.addNavigationView = addNavigationView
        self.content = content
    }
    
    public var body: some View {
        OptionalNavigationView(addNavigationView: addNavigationView, router: router) {
            content(router)
                .showingScreen(option: router.segueOption, items: $router.screens.value)
        }
        .onAppear(perform: {
            router.configure(presentationMode: presentationMode)
        })
        .showingAlert(option: router.alertOption, item: $router.alert)
        .showingModal(configuration: router.modalConfiguration, item: $router.modal)
    }
}

struct OptionalNavigationView<Content:View>: View {
    
    let addNavigationView: Bool
    let router: Router
    @ViewBuilder var content: Content
    
    @ViewBuilder var body: some View {
        if addNavigationView {
            if #available(iOS 16.0, *) {
                // TODO: Make this an extension in Binding.swift?
                let bindingToScreens = Binding(get: {
                    router.screens.value
                }, set: { newValue, _ in
                    router.screens.value = newValue
                })
                let path = Binding(if: router.segueOption, is: .push, value: bindingToScreens)
                
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
        RouterView(addNavigationView: true) { router in
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
