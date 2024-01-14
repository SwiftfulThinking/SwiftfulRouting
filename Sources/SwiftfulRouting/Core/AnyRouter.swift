//
//  AnyRouter.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

// Note (possible SwiftUI bug?):
// Do not conform to Equatable here. It causes the @State property wrapper to monitor Equatable value instead of Hashable value
// so didSegue changing value does not update the View (I think)
public struct AnyRoute: Identifiable, Equatable {
    public let id = UUID().uuidString
    let segue: SegueOption
    let onDismiss: (() -> Void)?
    let destination: (AnyRouter) -> any View
    
    public init(_ segue: SegueOption, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> any View) {
        self.segue = segue
        self.onDismiss = onDismiss
        self.destination = destination
    }
    
    static var root: AnyRoute = {
        var route = AnyRoute(.push) { router in
            AnyView(Text("Root"))
        }
        return route
    }()
    
    public static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        lhs.id == rhs.id
    }
}

public struct PushRoute: Identifiable {
    public let id = UUID().uuidString
    let segue: SegueOption = .push
    let onDismiss: (() -> Void)?
    let destination: (AnyRouter) -> any View
    
    public init(onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> any View) {
        self.onDismiss = onDismiss
        self.destination = destination
    }
    
    var asAnyRoute: AnyRoute {
        AnyRoute(segue, onDismiss: onDismiss, destination: destination)
    }
}

/// Type-erased Router with convenience methods.
public struct AnyRouter: Router {
    private let object: any Router

    public init(object: any Router) {
        self.object = object
    }
    
    /// Show any screen via Push (NavigationLink), Sheet, or FullScreenCover.
    public func showScreen<T>(_ option: SegueOption, onDismiss: (() -> Void)? = nil, @ViewBuilder destination: @escaping (AnyRouter) -> T) where T : View {
        object.showScreens([AnyRoute(option, onDismiss: onDismiss, destination: destination)])
    }

    /// Show any screen via Push (NavigationLink), Sheet, or FullScreenCover.
    public func showScreen(_ route: AnyRoute) {
        object.showScreens([route])
    }
    
    /// Show a flow of screens, segueing to the first route immediately. The following routes can be accessed via 'showNextScreen()'.
    public func showScreens(_ routes: [AnyRoute]) {
        object.showScreens(routes)
    }
    
    /// Shows the next screen set in the current screen flow. This would have been set previously via showScreens().
    public func showNextScreen() throws {
        try object.showNextScreen()
    }
    
    /// If there is a next screen in the current screen flow, go to it. Otherwise, flow is complete and dismiss the environment.
    public func showNextScreenOrDismissEnvironment() {
        do {
            try showNextScreen()
        } catch {
            dismissEnvironment()
        }
    }
    
    /// Dismiss the top-most presented environment (this would be the top-most sheet or fullScreenCover).
    public func dismissEnvironment() {
        object.dismissEnvironment()
    }
    
    /// Dismiss the top-most presented screen in the current Environment. Same as calling presentationMode.wrappedValue.dismiss().
    public func dismissScreen() {
        object.dismissScreen()
    }

    /// Push a stack of screens and show the last one immediately.
    @available(iOS 16, *)
    public func pushScreenStack(destinations: [PushRoute]) {
        object.pushScreenStack(destinations: destinations)
    }
    
    /// Show a resizeable sheet on top of the current context.
    @available(iOS 16, *)
    public func showResizableSheet<V>(sheetDetents: Set<PresentationDetentTransformable>, selection: Binding<PresentationDetentTransformable>?, showDragIndicator: Bool, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> V) where V : View {
        object.showResizableSheet(sheetDetents: sheetDetents, selection: selection, showDragIndicator: showDragIndicator, onDismiss: onDismiss, destination: destination)
    }
        
    /// Dismiss all NavigationLinks in NavigationStack heirarchy.
    ///
    ///  WARNING: Does not dismiss Sheet or FullScreenCover.
    @available(iOS 16, *)
    public func dismissScreenStack() {
        object.dismissScreenStack()
    }
    
    /// Show any Alert or ConfirmationDialog.
    ///
    ///  WARNING: Alert modifiers were deprecated between iOS 14 & iOS 15. iOS 15+ will use '@ViewBuilder alert' parameter, while iOS 14 and below will use 'buttonsiOS13' parameter.
    @available(iOS 15, *)
    public func showAlert<T:View>(_ option: AlertOption, title: String, subtitle: String? = nil, @ViewBuilder alert: @escaping () -> T) where T : View {
        object.showAlert(option, title: title, subtitle: subtitle, alert: alert, buttonsiOS13: nil)
    }
    
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
