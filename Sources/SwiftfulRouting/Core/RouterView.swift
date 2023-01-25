//
//  SwiftUIView.swift
//  
//
//  Created by Nick Sarno on 4/30/22.
//

import SwiftUI

/// Create a top-level RouterView
///
/// There should only be 1 RouterView per view heirarchy. The content will be wrapped in a NavigationView.
public struct RouterView<T:View>: View {
    
    @Environment(\.presentationMode) var presentationMode
    let content: (Router) -> T

    public init(@ViewBuilder content: @escaping (Router) -> T) {
        self.content = content
    }
    
    public var body: some View {
        NavigationView {
            SubRouterView(isTopRouter: true, content: content)
        }
    }
}

public struct SubRouterView<T:View>: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var router = Router()
    let isTopRouter: Bool
    let content: (Router) -> T

    public init(isTopRouter: Bool = false, @ViewBuilder content: @escaping (Router) -> T) {
        self.isTopRouter = isTopRouter
        self.content = content
    }
    
    public var body: some View {
        content(router)
            .onAppear(perform: {
                router.configure(presentationMode: presentationMode)
            })
            .showingAlert(option: router.alertOption, item: $router.alert)
            .showingScreen(option: router.segueOption, item: $router.screen)
            .showingModal(configuration: router.modalConfiguration, item: $router.modal)
            .environmentObject(router)
            .environmentObject(if: isTopRouter, TopRouter(router: router))
    }
}

extension View {
    
    
    @ViewBuilder func environmentObject(if isActive: Bool, _ object: some ObservableObject) -> some View {
        if isActive {
            self.environmentObject(object)
        } else {
            self
        }
    }
    
}


struct RouterView_Previews: PreviewProvider {
    static var previews: some View {
        RouterView { router in
            Text("Hi")
                .onTapGesture {
                    router.showScreen(.push) {
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
