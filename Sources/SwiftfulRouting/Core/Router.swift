//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI
import Combine

public protocol Router {
    func showScreen<V:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> V)
    func dismissScreen()

    @available(iOS 16, *)
    func pushScreens(destinations: [(AnyRouter) -> any View])
    
    @available(iOS 16, *)
    func popToRoot()
    
    @available(iOS 16, *)
    func showResizableSheet<V:View>(config: SheetConfig, @ViewBuilder destination: @escaping (AnyRouter) -> V)
    
    @available(iOS 15, *)
    func showAlert<V:View>(_ option: AlertOption, title: String, subtitle: String?, @ViewBuilder alert: @escaping () -> V)
    
    @available(iOS 15, *)
    func dismissAlert()
    
    func showModal<V:View>(transition: AnyTransition, animation: Animation, alignment: Alignment, backgroundColor: Color?, backgroundEffect: BackgroundEffect?, useDeviceBounds: Bool, @ViewBuilder destination: @escaping () -> V)
    func dismissModal()
}
