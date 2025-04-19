//
//  RouterEnvironmentKey.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import SwiftUI

public struct RouterEnvironmentKey: EnvironmentKey {
    public static let defaultValue: AnyRouter = AnyRouter(object: MockRouter())
}

public extension EnvironmentValues {
    var router: AnyRouter {
        get { self[RouterEnvironmentKey.self] }
        set { self[RouterEnvironmentKey.self] = newValue }
    }
}
