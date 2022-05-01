//
//  SwiftUIView.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI

struct NavigationViewIfNeeded<T:View>: View {
    
    let viewIsPresented: Bool
    let content: () -> T
    
    init(presentationMode: Binding<PresentationMode>?, @ViewBuilder content: @escaping () -> T) {
        self.viewIsPresented = presentationMode?.wrappedValue.isPresented ?? false
        self.content = content
    }
    
    var body: some View {
        if viewIsPresented {
            content()
        } else {
            NavigationView {
                content()
            }
        }
    }
}
