//
//  EnvironmentBackgroundOption.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public enum EnvironmentBackgroundOption {
    case automatic
    case clear
    case custom(any ShapeStyle)
}

extension View {
    
    @ViewBuilder
    func applyEnvironmentBackgroundIfAvailable(option: EnvironmentBackgroundOption) -> some View {
        if #available(iOS 16.4, *) {
            switch option {
            case .automatic:
                let _ = print("🔵 [EnvironmentBackground] Using automatic background")
                self
            case .clear:
                let _ = print("🔵 [EnvironmentBackground] Applying CLEAR background with RemoveSheetShadow")
                self
                    .presentationBackground(.clear)
                    .background(RemoveSheetShadow())
            case .custom(let value):
                let _ = print("🔵 [EnvironmentBackground] Applying custom background")
                self
                    .presentationBackground(AnyShapeStyle(value))
            }
        } else {
            switch option {
            case .automatic:
                let _ = print("🔵 [EnvironmentBackground] Using automatic background (iOS < 16.4)")
                self
            case .clear:
                let _ = print("🔵 [EnvironmentBackground] Applying CLEAR background (iOS < 16.4)")
                self
                    .background(RemoveSheetShadow())
            case .custom(let value):
                let _ = print("🔵 [EnvironmentBackground] Applying custom background (iOS < 16.4)")
                self
            }
        }
    }
}

fileprivate struct RemoveSheetShadow: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        print("🟣 [RemoveSheetShadow] makeUIView called")
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            print("🟣 [RemoveSheetShadow] Searching for shadow view...")
            if let shadowView = view.dropShadowView {
                print("🟣 [RemoveSheetShadow] ✅ Found shadow view! Clearing it.")
                shadowView.layer.shadowColor = UIColor.clear.cgColor
            } else {
                print("🟣 [RemoveSheetShadow] ❌ Shadow view NOT found")
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {

    }
}

extension UIView {
    var dropShadowView: UIView? {
        if let superview, String(describing: type(of: superview)) == "UIDropShadowView" {
            return superview
        }
        
        return superview?.dropShadowView
    }
}
