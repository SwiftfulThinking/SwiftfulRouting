//
//  AnyRouter.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

public struct RoutableDelegate {
    let goToNextScreen: (() -> Void)?
    let dismissEnvironment: (() -> Void)?
}

public struct Route {
    let id = UUID().uuidString
    let segue: SegueOption
    let screen: (AnyRouter) -> any View
    
    public init(segue: SegueOption, screen: @escaping (AnyRouter) -> any View) {
        self.segue = segue
        self.screen = screen
    }
}

/// Type-erased Router with convenience methods.
public struct AnyRouter: Router {
    private let object: any Router
    
    private var routable: RoutableDelegate? = nil

    public init(object: any Router) {
        self.object = object
    }
    
    // Make this so that I can customize the flow each time
    
    // ScreenQueue(id: UUID().uuidString, segue: SegueOption, screen: (AnyRouter) -> some View)
    
    public func showScreenStack(screens: [Route]) {
        var environmentRouter: AnyRouter? = nil
                
        func nextScreen(id: String, router: AnyRouter) -> AnyView {
            var router = router
            let index = screens.firstIndex(where: { $0.id == id }) ?? 0
            let screenData = screens[index]

            // Set environment router when seguing to new environment
            switch screenData.segue {
            case .push:
                break
            case .sheet, .fullScreenCover, .sheetDetents:
                environmentRouter = router
            }

            var dismissEnvironment: (() -> Void)?
            if let environmentRouter {
                dismissEnvironment = {
                    environmentRouter.dismissScreen()
                }
            }
            
            var goToNextScreen: (() -> Void)? = nil
            if screens.indices.contains(index + 1) {
                goToNextScreen = {
                    let nextScreenData = screens[index + 1]
                    router.showScreen(nextScreenData.segue) { childRouter in
                        nextScreen(id: nextScreenData.id, router: childRouter)
                    }
                }
            }
            
            let delegate = RoutableDelegate(goToNextScreen: goToNextScreen, dismissEnvironment: dismissEnvironment)
            router.setRoutable(delegate: delegate)
            
            return AnyView(screenData.screen(router))
        }
        
        showScreen(screens.first?.segue ?? .fullScreenCover) { router in
            nextScreen(id: screens.first?.id ?? "", router: router)
        }
    }
    
    public func showNextScreen() throws {
        guard let routable, let nextScreen = routable.goToNextScreen else {
            throw RoutableError.noNextScreenSet
        }
        nextScreen()
    }
    
    public func tryGoToNextScreenOrDismissEnvironment() throws {
        do {
            try showNextScreen()
        } catch {
            try dismissEnvironment()
        }
    }
    
    private enum RoutableError: LocalizedError {
        case noNextScreenSet
        case noDismissEnvironmentSet
    }
    
    public func dismissEnvironment() throws {
        guard let routable, let dismiss = routable.dismissEnvironment else {
            throw RoutableError.noDismissEnvironmentSet
        }
        dismiss()
    }
    
    private mutating func setRoutable(delegate: RoutableDelegate) {
        self.routable = delegate
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
