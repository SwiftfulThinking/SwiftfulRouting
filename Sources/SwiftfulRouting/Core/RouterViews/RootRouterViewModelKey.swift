//
//  RootRouterViewModelKey.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 3/21/26.
//
import SwiftUI

/// Environment key that carries a reference to the topmost RouterViewModel in the hierarchy.
/// Unlike @EnvironmentObject, this custom key is not shadowed when nested RouterViews
/// inject their own RouterViewModel — it always points to the original root.
struct RootRouterViewModelKey: EnvironmentKey {
    static let defaultValue: RouterViewModel? = nil
}

extension EnvironmentValues {
    var rootRouterViewModel: RouterViewModel? {
        get { self[RootRouterViewModelKey.self] }
        set { self[RootRouterViewModelKey.self] = newValue }
    }
}
