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
    let buttonsiOS14: AnyAlertiOS14Buttons?

    init<T:View>(title: String, subtitle: String? = nil, buttons: T, buttonsiOS14: AnyAlertiOS14Buttons? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.buttons = AnyView(buttons)
        self.buttonsiOS14 = buttonsiOS14
    }
    
    /// iOS 14 support
    var alert: Alert {
        let titleView = Text(title)
        
        var subtitleView: Text? = nil
        if let subtitle {
            subtitleView = Text(subtitle)
        }
        
        if let primaryButton = buttonsiOS14?.primaryButton, let secondaryButton = buttonsiOS14?.secondaryButton {
            return Alert(
                title: titleView,
                message: subtitleView,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton)
        } else {
            return Alert(
                title: titleView,
                message: subtitleView,
                dismissButton: buttonsiOS14?.primaryButton)
        }
    }
}

public struct AnyAlertiOS14Buttons {
    let primaryButton: Alert.Button?
    let secondaryButton: Alert.Button?
    
    public init(primaryButton: Alert.Button?, secondaryButton: Alert.Button?) {
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}
//
//struct AnyAlertiOS14: Identifiable {
//    let id = UUID().uuidString
//    let title: String
//    let subtitle: String?
//    let primaryButton: Alert.Button?
//    let secondaryButton: Alert.Button?
//
//    var alert: Alert {
//        let titleView = Text(title)
//        
//        var subtitleView: Text? = nil
//        if let subtitle {
//            subtitleView = Text(subtitle)
//        }
//        
//        if let primaryButton, let secondaryButton {
//            return Alert(
//                title: titleView,
//                message: subtitleView,
//                primaryButton: primaryButton,
//                secondaryButton: secondaryButton)
//        } else {
//            return Alert(
//                title: titleView,
//                message: subtitleView,
//                dismissButton: primaryButton)
//        }
//    }
//}
