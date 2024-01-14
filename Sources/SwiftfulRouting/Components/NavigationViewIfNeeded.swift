//
//  NavigationViewIfNeeded.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

struct NavigationViewIfNeeded<Content:View>: View {
    
    let addNavigationView: Bool
    let segueOption: SegueOption
    let onDismiss: (() -> Void)?
    @Binding var screens: [AnyDestination]
    @ViewBuilder var content: Content
    
    @ViewBuilder var body: some View {
        if addNavigationView {
            if #available(iOS 16.0, *) {
                NavigationStackTransformable(segueOption: segueOption, screens: $screens) {
                    content
                }
            } else {
                NavigationView {
                    content
                }
                //.onChangeOfPresentationMode(onDismiss: onDismiss)
            }
        } else {
            content
                .onChangeOfPresentationMode(segueOption: segueOption, screens: $screens, onDismiss: onDismiss)
        }
    }
}

struct OnChangeOfPresentationModeViewModifier: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode
    let segueOption: SegueOption
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
                    print(screens.count)
                }
            }
    }
}

extension View {
    
    func onChangeOfPresentationMode(segueOption: SegueOption, screens: Binding<[AnyDestination]>, onDismiss: (() -> Void)?) -> some View {
        modifier(OnChangeOfPresentationModeViewModifier(segueOption: segueOption, screens: screens, onDismiss: onDismiss))
    }
}


@available(iOS 16, *)
struct NavigationStackTransformable<Content:View>: View {
    
    // Convert [AnyDestination] to NavigationPath
    // Note: it works without the conversion, but there is a warning in console.
    // "Only root-level navigation destinations are effective for a navigation stack with a homogeneous path"
    // Since we have this conversion, we have to keep both screens and path in sync at all times
    // We have to observe the path to monitor native screen dismissal that aren't via router.dismiss
    
    let segueOption: SegueOption
    @Binding var screens: [AnyDestination]
    @ViewBuilder var content: Content

    @State private var path: NavigationPath = .init()
    @State private var isPushEnabled: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
        .onAppear {
            isPushEnabled = segueOption == .push
        }
        .onChange(of: segueOption, perform: { newValue in
            isPushEnabled = newValue == .push
        })
        .onChange(of: screens) { newValue in
            if isPushEnabled {
                path = .init(newValue)
            }
        }
        .onChange(of: path, perform: { path in
            if path.count < screens.count {
                screens.removeLast()
                print("DID REMOVE LAST SCREEN")
            }
        })
    }
    
}
