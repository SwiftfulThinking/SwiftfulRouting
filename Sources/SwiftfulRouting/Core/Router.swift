//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI

// remove top router
// remove environment objects
// remove RouterView, only have SubRouter view? NavigationView is for user to add? no?

/// Contains an instance of Router. Created as a seperate class so that it can exist in the environment alongside the default routers.
public class TopRouter: ObservableObject {
    
    public let router: Router
    
    public init(router: Router) {
        self.router = router
    }
    
}

/// Each Router can support 1 active segue, 1 active modal, and 1 active alert.
@MainActor
public class Router: ObservableObject {
        
    var presentationMode: Binding<PresentationMode>? = nil
    
    @Published private(set) var segueOption: SegueOption = .push
    @Published var screen: AnyDestination? = nil
    
    @Published private(set) var alertOption: AlertOption = .alert
    @Published var alert: AnyAlert? = nil
    
    @Published private(set) var modalConfiguration: ModalConfiguration = .default
    @Published var modal: AnyDestination? = nil
    
    func configure(presentationMode: Binding<PresentationMode>?) {
        self.screen = nil
        self.presentationMode = presentationMode
    }
        
    public func showScreen<T:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (Router) -> T) {
        guard self.screen == nil else {
            print("Cannot segue because a destination has already been set in this router.")
            return
        }
        self.segueOption = option

        // To do: Must wait 0.01 seconds between updating segueOption and screen or segue will not execute.
        // Need to figure out why that is and hopefully remove any delay / sleep.
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000) // 0.01 seconds
            await MainActor.run(body: {
                switch option {
                case .sheet, .fullScreenCover:
                    self.screen = AnyDestination(RouterView { router in
                        destination(router)
                    })
                case .push:
                    self.screen = AnyDestination(SubRouterView { router in
                        destination(router)
                    })
                }
            })
        }
    }
    
    public func dismissScreen() {
        self.presentationMode?.wrappedValue.dismiss()
    }
    
    public func showAlert<T:View>(_ option: AlertOption, title: String, @ViewBuilder alert: @escaping () -> T) {
        guard self.alert == nil else {
            dismissAlert()
            return
        }
        
        self.alertOption = option
        self.alert = AnyAlert(title: title, buttons: alert())
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
