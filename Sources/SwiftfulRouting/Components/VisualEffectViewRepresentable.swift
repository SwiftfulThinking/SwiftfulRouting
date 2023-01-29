//
//  VisualEffectViewRepresentable.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

public struct VisualEffectViewRepresentable: UIViewRepresentable {
    
    let effect: UIVisualEffect
    
    public init(effect: UIVisualEffect) {
        self.effect = effect
    }
    
    public func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        view.effect = effect
        return view
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        
    }
    
}
