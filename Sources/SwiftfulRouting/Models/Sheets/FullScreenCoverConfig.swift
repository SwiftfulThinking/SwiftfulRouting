//
//  FullScreenCoverConfig.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public struct FullScreenCoverConfig {
    var background: EnvironmentBackgroundOption

    public init(
        background: EnvironmentBackgroundOption = .automatic
    ) {
        self.background = background
    }
}
