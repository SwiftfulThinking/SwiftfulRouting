//
//  NavigationViewIfNeeded.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation
import SwiftUI

struct NavigationViewIfNeeded<Content:View>: View {
    
    let addNavigationView: Bool
    let segueOption: SegueOption
    @Binding var screens: [AnyDestination]
    @ViewBuilder var content: Content
    
    @ViewBuilder var body: some View {
        if addNavigationView {
            if #available(iOS 16.0, *) {
//                NavigationStack(path: Binding(if: segueOption, is: .push, value: $screens)) {
//                    content
//                }
                NavigationStackTransformable(segueOption: segueOption, screens: $screens) {
                    content
                }
            } else {
                NavigationView {
                    content
                }
            }
        } else {
            content
        }
    }
}

@available(iOS 16, *)
struct NavigationStackTransformable<Content:View>: View {
    
    // Convert [AnyDestination] to NavigationPath
    // Note: it works without the conversion, but there is a warning in console.
    // "Only root-level navigation destinations are effective for a navigation stack with a homogeneous path"
    
    let segueOption: SegueOption
    @Binding var screens: [AnyDestination]
    @ViewBuilder var content: Content

    @State private var path: NavigationPath = .init()

    var body: some View {
        NavigationStack(path: $path) {
            content
        }
        .onChange(of: segueOption, perform: { newValue in
            print("SEGUE CHANGE: \(newValue)")
        })
        .onChange(of: screens) { newValue in
            print("NEW VALUE and \(segueOption)")
            if segueOption == .push {
                path = .init(newValue)
            }
        }
    }
    
    
}


//@available(iOS 16.0, *)
//struct CealUIApp: View {
//    @State private var path: NavigationPath = .init()
//    var body: some View {
//        NavigationStack(path: $path){
//            OnBoardingView(path: $path)
//                .navigationDestination(for: ViewOptions.self) { option in
//                    option.view($path)
//                }
//        }
//    }
//    //Create an `enum` so you can define your options
//    enum ViewOptions{
//        case userTypeView
//        case register
//        //Assign each case with a `View`
//        @ViewBuilder func view(_ path: Binding<NavigationPath>) -> some View{
//            switch self{
//            case .userTypeView:
//                UserTypeView(path: path)
//            case .register:
//                RegisterView()
//            }
//        }
//    }
//}
//@available(iOS 16.0, *)
//struct OnBoardingView: View {
//    @Binding var path: NavigationPath
//    var body: some View {
//        Button {
//            //Append to the path the enum value
//
//            path.append(CealUIApp.ViewOptions.userTypeView)
//        } label: {
//            Text("Hello")
//        }
//
//    }
//}
//@available(iOS 16.0, *)
//struct UserTypeView: View {
//    @Binding var path: NavigationPath
//    var body: some View {
//        Button {
//            //Append to the path the enum value
//            path.append(CealUIApp.ViewOptions.register)
//        } label: {
//            Text("Hello")
//        }
//
//    }
//}
//@available(iOS 16.0, *)
//struct RegisterView: View {
//    var body: some View {
//        Text("Register")
//
//    }
//}
//@available(iOS 16.0, *)
//struct CealUIApp_Previews: PreviewProvider {
//    static var previews: some View {
//        CealUIApp()
//    }
//}
