//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/10/24.
//

import Foundation
import SwiftUI
import SwiftfulUI

struct TransitionSupportViewWrapper<Content:View>: View {
    
    let configuration: TransitionConfiguration
    let destination: AnyDestination?
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            LazyZStack(
                selection: destination != nil,
                view: { (didTransition: Bool) in
                    if didTransition {
                        ZStack {
                            if let view = destination?.destination {
                                view
                            }
                        }
                        .transition(configuration.insertingNext)
                    } else {
                        content
                            .transition(configuration.removingCurrent)
                    }
                }
            )
            .animation(configuration.animation, value: destination == nil)
        }
    }
}
