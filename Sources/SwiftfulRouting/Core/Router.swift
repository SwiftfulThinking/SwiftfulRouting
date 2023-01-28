//
//  Router.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import SwiftUI
import Combine

/// Each Router can support 1 active segue, 1 active modal, and 1 active alert.
//@MainActor
//public class Router: ObservableObject {
//        
//    
//    @Published private(set) var segueOption: SegueOption = .push
//    @Published var screens: CurrentValueSubject<[AnyDestination], Never> = CurrentValueSubject([])
////    @Published var screens: [AnyDestination] = []
//    
//    @Published private(set) var alertOption: AlertOption = .alert
//    @Published var alert: AnyAlert? = nil
//    
//    @Published private(set) var modalConfiguration: ModalConfiguration = .default
//    @Published var modal: AnyDestination? = nil
//    
//    public init(addNavigationView: Bool = true, screens: (CurrentValueSubject<[AnyDestination], Never>)? = nil) {
//        self.addNavigationView = addNavigationView
//        self.screens = screens ?? CurrentValueSubject([])
//    }
//    
//    func configure(presentationMode: Binding<PresentationMode>?) {
//        self.screens.send([])
//        self.presentationMode = presentationMode
//    }
//        
//    public func showScreen<T:View>(_ option: SegueOption, @ViewBuilder destination: @escaping (Router) -> T) {
////        guard self.screens.isEmpty else {
////            print("Cannot segue because a destination has already been set in this router.")
////            return
////        }
//        self.segueOption = option
//
//        // Push maintains the current NavigationView
//        // Sheet and FullScreenCover enter new Environemnts and require a new one to be added.
//        let shouldAddNavigationView = option != .push
//        self.screens.send([
//            AnyDestination(
//                RouterView(
//                    router: Router(
//                        addNavigationView: shouldAddNavigationView,
//                        screens: shouldAddNavigationView ? nil : screens),
//                    content: destination)
//            )
//        ])
//    }
//    
//    
//    
//}
