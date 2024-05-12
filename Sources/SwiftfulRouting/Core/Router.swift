//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI
import Combine

public protocol Router {
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
    
    func showAlert<T:View>(_ option: DialogOption, title: String, subtitle: String?, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]?)
    
    func dismissAlert()
    
    func showModal<V:View>(id: String?, transition: AnyTransition, animation: Animation, alignment: Alignment, backgroundColor: Color?, dismissOnBackgroundTap: Bool, ignoreSafeArea: Bool, @ViewBuilder destination: @escaping () -> V)
    func dismissModal(id: String?)
    func dismissAllModals()
    
    func showSafari(_ url: @escaping () -> URL)
}
