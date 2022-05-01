//
//  SwiftUIView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

/// Create a top-level RouterView
///
/// The content will be wrapped in a NavigationView. The developer modify the nav bars using the native SwiftUI modifiers.
public struct RouterView<T:View>: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var router = Router()
    let content: () -> T

    public init(@ViewBuilder content: @escaping () -> T) {
        self.content = content
    }
    
    public var body: some View {
        NavigationViewIfNeeded(presentationMode: presentationMode) {
            content()
                .onAppear(perform: {
                    router.configure(presentationMode: presentationMode)
                })
                .showingAlert(option: router.alertOption, item: $router.alert)
                .showingScreen(option: router.segueOption, item: $router.screen)
                .showingModal(configuration: router.modalConfiguration, item: $router.modal)
                .environmentObject(router)
        }
    }
    
}

struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView {
            Text("Hi")
        }
    }
}

extension View {
    
    @ViewBuilder func showingScreen(option: SegueOption, item: Binding<AnyDestination?>) -> some View {
        if option == .sheet {
            modifier(SheetViewModifier(item: item))
        } else if option == .fullScreenCover {
            if #available(iOS 14.0, *) {
                modifier(FullScreenCoverViewModifier(item: item))
            } else {
                modifier(SheetViewModifier(item: item))
            }
        } else {
            modifier(NavigationLinkViewModifier(item: item))
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
