//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI

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
        
    public func showScreen<T:View>(_ option: SegueOption, @ViewBuilder destination: @escaping () -> T) {
        guard self.screen == nil else {
            print("Cannot segue because a destination has already been set in this router.")
            return
        }
        self.segueOption = option

        // To do: Must wait 0.01 seconds between updating screenType and screen or segue will not execute.
        // Need to figure out why that is and hopefully remove any delay / sleep.
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000) // 0.01 seconds
            await MainActor.run(body: {
                self.screen = AnyDestination(SubRouterView(content: { destination() }))
            })
        }
    }
    
    public func dismissScreen() {
        self.presentationMode?.wrappedValue.dismiss()
    }
    
    public func showAlert<T:View>(_ option: AlertOption, title: String, @ViewBuilder alert: @escaping () -> T) {
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
        self.modalConfiguration = ModalConfiguration(transition: transition, animation: animation, alignment: alignment, backgroundColor: backgroundColor, useDeviceBounds: useDeviceBounds)
        self.modal = AnyDestination(destination())
    }
    
    public func dismissModal() {
        self.modal = nil
    }
    
}
