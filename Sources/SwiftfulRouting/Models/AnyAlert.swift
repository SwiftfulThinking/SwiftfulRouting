//
//  AnyAlert.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct AnyAlert: Identifiable {
    let id = UUID().uuidString
    let title: String
    let buttons: AnyView

    init<T:View>(title: String, buttons: T) {
        self.title = title
        self.buttons = AnyView(buttons)
    }
}
