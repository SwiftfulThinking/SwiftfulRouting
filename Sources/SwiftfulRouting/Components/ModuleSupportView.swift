//
//  ModuleSupportView.swift
//
//
//  Created by Nick Sarno on 1/21/24.
//

import Foundation
import SwiftUI

struct ModuleSupportView<Content:View>: View {
    
    let addNavigationView: Bool
    let moduleDelegate: ModuleDelegate
    let screens: Binding<[AnyDestination]>?

    @Binding var selection: AnyTransitionWithDestination
    let modules: [AnyTransitionWithDestination]
    @ViewBuilder var content: (AnyRouter) -> Content
    let currentTransition: TransitionOption
    
    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: false, selection: selection, items: modules) { data in
                if data == modules.first {
                    RouterViewInternal(
                        addNavigationView: addNavigationView,
                        moduleDelegate: moduleDelegate,
                        screens: screens,
                        route: nil,
                        routes: nil,
                        environmentRouter: nil,
                        content: content
                    )
                    .onAppear {
                        print("DID APPEAR!!!!!")
                    }
//                    .background(Color.red)
//                    RouterView(addNavigationView: addNavigationView, screens: screens) { router in
//                        content(router)
//                    }
                    .transition(
                        .asymmetric(
                            insertion: currentTransition.insertion,
                            removal: .customRemoval(direction: currentTransition.reversed)
                        )
                    )
                } else {
                    RouterViewInternal(
                        addNavigationView: addNavigationView,
                        moduleDelegate: moduleDelegate,
                        screens: screens,
                        route: nil,
                        routes: nil,
                        environmentRouter: nil,
                        content: { router in
                            data.destination(router).destination
                        }
                    )
//                    RouterView(addNavigationView: addNavigationView, screens: screens) { router in
//                        data.destination(router).destination
//                    }
                    .transition(
                        .asymmetric(
                            insertion: currentTransition.insertion,
                            removal: .customRemoval(direction: currentTransition.reversed)
                        )
                    )
                }
            }
            .animation(.easeInOut, value: selection.id)
        }
    }
}
