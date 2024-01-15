//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/15/24.
//

import Foundation
import SwiftUI

/// Listen for changes to presentationMode and execute onDismiss if needed
/// This is required to support onDismiss for iOS below 16.0, since it uses NavigationView rather than NavigationStack.
struct OnChangeOfPresentationModeViewModifier: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var screens: [AnyDestination]
    let onDismiss: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onChange(of: presentationMode.wrappedValue.isPresented) { newValue in
                // Check screens.isEmpty to ensure there are no screens infront of this screen rendered
                // This is an edge case where if user pushes too far forward (~10+), the system will stop presenting lowest screens in heirarchy
                // (ie. this occurs iOS 15 via sheet, push, push, push...
                if !newValue, screens.isEmpty {
                    onDismiss?()
                }
            }
    }
}

extension View {
    
    func onChangeOfPresentationMode(screens: Binding<[AnyDestination]>, onDismiss: (() -> Void)?) -> some View {
        modifier(OnChangeOfPresentationModeViewModifier(screens: screens, onDismiss: onDismiss))
    }
}
