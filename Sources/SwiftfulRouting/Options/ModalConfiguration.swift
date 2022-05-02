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
    let useDeviceBounds: Bool
    
    static let `default` = ModalConfiguration(
        transition: .move(edge: .bottom),
        animation: .easeInOut,
        alignment: .bottom,
        backgroundColor: nil,
        useDeviceBounds: true)
}
