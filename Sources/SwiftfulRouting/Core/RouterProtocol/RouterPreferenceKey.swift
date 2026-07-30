//
//  RouterPreferenceKey.swift
//  SwiftfulRouting
//
//  Created by Andrew Coyle on 25/01/2026.
//

import SwiftUI

// PreferenceKey to capture router from tabs
private struct RouterPreferenceKey: PreferenceKey {
    static var defaultValue: AnyRouter? {
        nil
    }

    static func reduce(value: inout AnyRouter?, nextValue: () -> AnyRouter?) {
        // Use the first non-nil router we encounter
        if value == nil {
            value = nextValue()
        }
    }
}

// View modifier to set router preference
struct RouterPreferenceModifier: ViewModifier {
    let router: AnyRouter
    
    func body(content: Content) -> some View {
        content
            .preference(key: RouterPreferenceKey.self, value: router)
    }
}
