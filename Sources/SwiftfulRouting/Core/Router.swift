//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI
import Combine

public protocol Router {
    var screens: [AnyDestination] { get }
    func showScreen<V:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> V)
    func dismissScreen()

    @available(iOS 16, *)
    func pushScreens(destinations: [(AnyRouter) -> any View])
    
    @available(iOS 16, *)
    func popToRoot()
    
    @available(iOS 16, *)
    func showResizableSheet<V:View>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool, @ViewBuilder destination: @escaping (AnyRouter) -> V)
    
    @available(iOS 16.4, *)
    func showPopover<V:View>(_ anchor: PopoverAttachmentAnchor, @ViewBuilder destination: @escaping (AnyRouter) -> V)
    
    func showAlert<T:View>(_ option: AlertOption, title: String, subtitle: String?, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]?)
    
    func dismissAlert()
    
    func showModal<V:View>(transition: AnyTransition, animation: Animation, alignment: Alignment, backgroundColor: Color?, backgroundEffect: BackgroundEffect?, useDeviceBounds: Bool, @ViewBuilder destination: @escaping () -> V)
    func dismissModal()
    
    func showSafari(_ url: @escaping () -> URL)
}
