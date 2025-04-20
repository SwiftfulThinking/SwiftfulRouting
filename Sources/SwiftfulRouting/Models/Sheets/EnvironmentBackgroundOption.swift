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
                self
            case .clear:
                self
                    .presentationBackground(.clear)
                    .background(RemoveSheetShadow())
            case .custom(let value):
                self
                    .presentationBackground(AnyShapeStyle(value))
            }
        } else {
            switch option {
            case .automatic:
                self
            case .clear:
                self
                    .background(RemoveSheetShadow())
            case .custom(let value):
                self
            }
        }
    }
}

fileprivate struct RemoveSheetShadow: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        DispatchQueue.main.async {
            if let shadowView = view.dropShadowView {
                shadowView.layer.shadowColor = UIColor.clear.cgColor
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
