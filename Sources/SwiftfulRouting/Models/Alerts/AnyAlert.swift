//
//  AnyAlert.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//
import Foundation
import SwiftUI

public struct AnyAlert: Identifiable {
    public let id = UUID().uuidString
    public let style: AlertStyle
    public let location: AlertLocation
    public let title: String
    public let subtitle: String?
    public let buttons: AnyView
    
    /// Display an alert.
    /// - Parameters:
    ///   - style: Type of alert.
    ///   - location: Which screen to display alert on.
    ///   - title: Title of alert.
    ///   - subtitle: Subtitle of alert (optional)
    ///   - buttons: Buttons within alert (hint: use Group with multiple Button inside).
    public init<T:View>(
        style: AlertStyle = .alert,
        location: AlertLocation = .topScreen,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder buttons: () -> T
    ) {
        self.style = style
        self.location = location
        self.title = title
        self.subtitle = subtitle
        self.buttons = AnyView(buttons())
    }
    
    /// Display an alert with "OK" button.
    /// - Parameters:
    ///   - style: Type of alert.
    ///   - location: Which screen to display alert on.
    ///   - title: Title of alert.
    ///   - subtitle: Subtitle of alert (optional)
    public init(
        style: AlertStyle = .alert,
        location: AlertLocation = .topScreen,
        title: String,
        subtitle: String? = nil
    ) {
        self.style = style
        self.location = location
        self.title = title
        self.subtitle = subtitle
        self.buttons = AnyView(
            Button("OK", action: { })
        )
    }
    
    public var eventParameters: [String: Any] {
        [
            "alert_id": id,
            "alert_style": style.rawValue,
            "alert_location": location.rawValue,
            "alert_title": title,
            "alert_subtitle": subtitle ?? "",
        ]
    }
}
