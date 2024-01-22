//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI
import Combine

public protocol Router: ModuleDelegate {
    func enterScreenFlow(_ routes: [AnyRoute])
    func showNextScreen() throws
    func dismissScreen()
    func dismissEnvironment()
    @available(iOS 16, *)
    func dismissScreenStack()

    @available(iOS 16, *)
    func pushScreenStack(destinations: [PushRoute])
    
    
    @available(iOS 16, *)
    func showResizableSheet<V:View>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool, onDismiss: (() -> Void)?, @ViewBuilder destination: @escaping (AnyRouter) -> V)
    
    func showAlert<T:View>(_ option: AlertOption, title: String, subtitle: String?, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]?)
    
    func dismissAlert()
    
    func showModal<V:View>(id: String?, transition: AnyTransition, animation: Animation, alignment: Alignment, backgroundColor: Color?, ignoreSafeArea: Bool, @ViewBuilder destination: @escaping () -> V)
    func dismissModal(id: String?)
    func dismissAllModals()
    
    func transitionScreen<T>(_ option: TransitionOption, @ViewBuilder destination: @escaping (AnyRouter) -> T) where T : View
    func dismissTransition()
    func dismissAllTransitions()
        
    func showSafari(_ url: @escaping () -> URL)
}

public protocol ModuleDelegate {
    func transitionModule<T>(_ option: TransitionOption, destination: @escaping (AnyRouter) -> T) where T : View
    func dismissModule()
    func dismissAllModules()
}
