//
//  AnyRouter.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

/// Type-erased Router with convenience methods.
public struct AnyRouter: Router {
    private let object: any Router
    
    public init(object: any Router) {
        self.object = object
    }
    
    public var screens: [AnyDestination] {
        object.screens
    }
    
    /// Show any screen via Push (NavigationLink), Sheet, or FullScreenCover.
    public func showScreen<T>(_ option: SegueOption, @ViewBuilder destination: @escaping (AnyRouter) -> T) where T : View {
        object.showScreen(option, destination: destination)
    }
    
    /// Dismiss the top-most presented screen in the current Environment. Same as calling presentationMode.wrappedValue.dismiss().
    public func dismissScreen() {
        object.dismissScreen()
    }

    /// Dismiss all NavigationLinks in NavigationStack heirarchy.
    @available(iOS 16, *)
    public func pushScreens(destinations: [(AnyRouter) -> any View]) {
        object.pushScreens(destinations: destinations)
    }
    
    @available(iOS 16, *)
    public func showResizableSheet<V>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool, destination: @escaping (AnyRouter) -> V) where V : View {
        object.showResizableSheet(sheetDetents: sheetDetents, selection: selection, showDragIndicator: showDragIndicator, destination: destination)
    }
    
    @available(iOS 16.4, *)
    public func showPopover<V:View>(anchor: PopoverAttachmentAnchor, @ViewBuilder destination: @escaping () -> V) {
        object.showPopover(anchor: anchor, destination: destination)
    }
    
    @available(iOS 16.4, *)
    public func dismissPopover() {
        object.dismissPopover()
    }
        
    /// Dismiss all NavigationLinks in NavigationStack heirarchy.
    ///
    ///  WARNING: Does not dismiss Sheet or FullScreenCover.
    @available(iOS 16, *)
    public func popToRoot() {
        object.popToRoot()
    }
    
    /// Show any Alert or ConfirmationDialog.
    ///
    ///  WARNING: Alert modifiers were deprecated between iOS 14 & iOS 15. iOS 15+ will use '@ViewBuilder alert' parameter, while iOS 14 and below will use 'buttonsiOS13' parameter.
    public func showAlert<T:View>(_ option: AlertOption, title: String, subtitle: String? = nil, @ViewBuilder alert: @escaping () -> T, buttonsiOS13: [Alert.Button]? = nil) where T : View {
        object.showAlert(option, title: title, subtitle: subtitle, alert: alert, buttonsiOS13: buttonsiOS13)
    }
    
    /// Convenience method for a simple alert with title text and ok button.
    public func showBasicAlert(text: String, action: (() -> Void)? = nil) {
        showAlert(.alert, title: text) {
            Button("OK") {
                action?()
            }
        }
    }
    
    /// Dismiss presented alert. Note: Alerts often dismiss themselves. Calling this anyway is ok.
    public func dismissAlert() {
        object.dismissAlert()
    }
    
    /// Show any Modal over the current Environment.
    public func showModal<T>(
        transition: AnyTransition = AnyTransition.opacity.animation(.default),
        animation: Animation = .default,
        alignment: Alignment = .center,
        backgroundColor: Color? = Color.black.opacity(0.001),
        backgroundEffect: BackgroundEffect? = nil,
        useDeviceBounds: Bool = true,
        @ViewBuilder destination: @escaping () -> T) where T : View {
        object.showModal(transition: transition, animation: animation, alignment: alignment, backgroundColor: backgroundColor, backgroundEffect: backgroundEffect, useDeviceBounds: useDeviceBounds, destination: destination)
    }
    
    /// Convenience method for a simple modal appearing over the current Environment in the center of the screen.
    public func showBasicModal<T>(@ViewBuilder destination: @escaping () -> T) where T : View {
        showModal(
            transition: AnyTransition.opacity.animation(.easeInOut),
            animation: .easeInOut,
            alignment: .center,
            backgroundColor: Color.black.opacity(0.4),
            useDeviceBounds: true,
            destination: destination)
    }
    
    public func dismissModal() {
        object.dismissModal()
    }
    
    /// Open URL in Safari app. To open url in in-app browser, use showSheet with a WebView.
    public func showSafari(_ url: @escaping () -> URL) {
        object.showSafari(url)
    }

}
