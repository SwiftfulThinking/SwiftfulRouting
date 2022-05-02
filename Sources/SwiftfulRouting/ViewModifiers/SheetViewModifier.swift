//
//  SheetViewModifier.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation
import SwiftUI

struct SheetViewModifier: ViewModifier {
    
    let item: Binding<AnyDestination?>

    func body(content: Content) -> some View {
        content
            .sheet(item: item, onDismiss: nil) { destination in
                NavigationView {
                    if let view = item.wrappedValue?.destination {
                        view
                            .onAppear {
                                print("NEW NAV ADDED")
                            }
                    }
                }
            }
    }
}
