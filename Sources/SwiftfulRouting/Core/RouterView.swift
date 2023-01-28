//
//  SwiftUIView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

/// RouterView adds modifiers for segues, alerts, and modals. Use the escaping Router to perform actions.
public struct RouterView<T:View>: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var router = Router()
    public let content: (Router) -> T
    
    public var body: some View {
        content(router)
            .onAppear(perform: {
                router.configure(presentationMode: presentationMode)
            })
            .showingAlert(option: router.alertOption, item: $router.alert)
            .showingScreen(option: router.segueOption, item: $router.screen)
            .showingModal(configuration: router.modalConfiguration, item: $router.modal)
            .environmentObject(router)
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
    
    @ViewBuilder func showingScreen(option: SegueOption, item: Binding<AnyDestination?>) -> some View {
        if #available(iOS 14, *) {
            self
                .modifier(NavigationLinkViewModifier(option: option, item: item))
                .modifier(SheetViewModifier(option: option, item: item))
                .modifier(FullScreenCoverViewModifier(option: option, item: item))
        } else {
            self
                .modifier(NavigationLinkViewModifier(option: option, item: item))
                .modifier(SheetViewModifier(option: option, item: item))
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
