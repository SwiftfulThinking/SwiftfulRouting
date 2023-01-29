//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

/// Type-erased Router
public struct AnyRouter: Router {
    let object: any Router
    
    public func showScreen<T>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> T) where T : View {
        object.showScreen(option, destination: destination)
    }
    
    public func dismissScreen() {
        object.dismissScreen()
    }

    @available(iOS 16, *)
    public func pushStack(destinations: [(AnyRouter) -> any View]) {
        object.pushStack(destinations: destinations)
    }
    
    @available(iOS 16, *)
    public func popToRoot() {
        object.popToRoot()
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
