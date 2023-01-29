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
    let subtitle: String?
    let buttons: AnyView
    let buttonsiOS13: [Alert.Button]?

    init<T:View>(title: String, subtitle: String? = nil, buttons: T, buttonsiOS13: [Alert.Button]? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = AnyView(buttons)
        self.buttonsiOS13 = buttonsiOS13
    }
    
    /// iOS 14 support for Alerts
    var alert: Alert {
        let titleView = Text(title)
        
        var subtitleView: Text? = nil
        if let subtitle {
            subtitleView = Text(subtitle)
        }
        
        if let buttonsiOS13, buttonsiOS13.indices.contains(1) {
            let primaryButton = buttonsiOS13[0]
            let secondaryButton = buttonsiOS13[1]
            return Alert(
                title: titleView,
                message: subtitleView,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton)
        } else {
            return Alert(
                title: titleView,
                message: subtitleView,
                dismissButton: buttonsiOS13?.first)
        }
    }
    
    /// iOS 14 support for ConfirmationDialog
    var actionSheet: ActionSheet {
        let titleView = Text(title)

        var subtitleView: Text? = nil
        if let subtitle {
            subtitleView = Text(subtitle)
        }

        return ActionSheet(title: titleView, message: subtitleView, buttons: buttonsiOS13 ?? [])
    }
}
