//
//  RootAnyRouterKey.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 3/23/26.
//
import SwiftUI

/// Environment key that carries a reference to the root AnyRouter in the hierarchy.
/// Unlike \.router (which is shadowed by each nested RouterView), this key always points to the outermost RouterView's router.
struct RootAnyRouterKey: EnvironmentKey {
    static let defaultValue: AnyRouter? = nil
}

extension EnvironmentValues {
    var rootRouter: AnyRouter? {
        get { self[RootAnyRouterKey.self] }
        set { self[RootAnyRouterKey.self] = newValue }
    }
}
