//
//  ModalConfiguration.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

public struct ModalConfiguration {
    let transition: AnyTransition
    let animation: Animation
    let alignment: Alignment
    let backgroundColor: Color?
    let dismissOnBackgroundTap: Bool
    let ignoreSafeArea: Bool
    
    static let `default` = ModalConfiguration(
        transition: .move(edge: .bottom),
        animation: .easeInOut,
        alignment: .bottom,
        backgroundColor: nil,
        dismissOnBackgroundTap: true,
        ignoreSafeArea: true
    )
}
