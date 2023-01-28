//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI
import Combine

/// Each Router can support 1 active segue, 1 active modal, and 1 active alert.
@MainActor
public class Router: ObservableObject {
        
    var presentationMode: Binding<PresentationMode>? = nil
    
    @Published private(set) var segueOption: SegueOption = .push
    var screens: CurrentValueSubject<[AnyDestination], Never> = CurrentValueSubject([])
//    @Published var screens: [AnyDestination] = []
    
    @Published private(set) var alertOption: AlertOption = .alert
    @Published var alert: AnyAlert? = nil
    
    @Published private(set) var modalConfiguration: ModalConfiguration = .default
    @Published var modal: AnyDestination? = nil
    
    func configure(presentationMode: Binding<PresentationMode>?) {
        self.screens.send([])
        self.presentationMode = presentationMode
    }
        
    public func showScreen<T:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (Router) -> T) {
//        guard self.screens.isEmpty else {
//            print("Cannot segue because a destination has already been set in this router.")
//            return
//        }
        self.segueOption = option

        // Push maintains the current NavigationView
        // Sheet and FullScreenCover enter new Environemnts and require a new one to be added.
        let shouldAddNavigationView = option != .push
        self.screens.send([AnyDestination(RouterView(addNavigationView: shouldAddNavigationView, content: destination))])
    }
    
    public func dismissScreen() {
        self.presentationMode?.wrappedValue.dismiss()
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
