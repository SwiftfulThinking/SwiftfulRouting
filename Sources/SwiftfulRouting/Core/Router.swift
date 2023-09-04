//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI
import Combine

public protocol Router {
    func showScreens(_ routes: [AnyRoute])
    func showNextScreen() throws
    func dismissScreen()
    func dismissEnvironment()
    @available(iOS 16, *)
    func dismissScreenStack()

    @available(iOS 16, *)
    func pushScreenStack(destinations: [(AnyRouter) -> any View])
    
    
    @available(iOS 16, *)
    func showResizableSheet<V:View>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool, @ViewBuilder destination: @escaping (AnyRouter) -> V)
    
    func showAlert<T:View>(_ option: AlertOption, title: String, subtitle: String?, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]?)
    
    func dismissAlert()
    
    func showModal<V:View>(transition: AnyTransition, animation: Animation, alignment: Alignment, backgroundColor: Color?, backgroundEffect: BackgroundEffect?, useDeviceBounds: Bool, @ViewBuilder destination: @escaping () -> V)
    func dismissModal()
    
    func showSafari(_ url: @escaping () -> URL)
}
