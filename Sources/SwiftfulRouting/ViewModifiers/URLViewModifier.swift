////
////  URLViewModifier.swift
////  
////
////  Created by Nick Sarno on 8/24/23.
////
//
//import Foundation
//import SwiftUI
//
//struct URLViewModifier: ViewModifier {
//    
//    let url: URL
//    
//    func body(content: Content) -> some View {
//        content
//            .background(
//                Link
//            )
////            .overlay(
////                ZStack {
////                    if let view = item.wrappedValue?.destination {
////
////                        if let backgroundColor = configuration.backgroundColor {
////                            backgroundColor
////                                .frame(maxWidth: .infinity, maxHeight: .infinity)
////                                .edgesIgnoringSafeArea(.all)
////                                .transition(AnyTransition.opacity.animation(configuration.animation))
////                                .onTapGesture {
////                                    item.wrappedValue = nil
////                                }
////                                .zIndex(1)
////                        }
////
////                        if let backgroundEffect = configuration.backgroundEffect {
////                            VisualEffectViewRepresentable(effect: backgroundEffect.effect)
////                                .opacity(backgroundEffect.opacity)
////                                .frame(maxWidth: .infinity, maxHeight: .infinity)
////                                .edgesIgnoringSafeArea(.all)
////                                .transition(AnyTransition.opacity.animation(configuration.animation))
////                                .onTapGesture {
////                                    item.wrappedValue = nil
////                                }
////                                .zIndex(2)
////                        }
////
////                        view
////                            .frame(configuration: configuration)
////                            .edgesIgnoringSafeArea(configuration.useDeviceBounds ? .all : [])
////                            .transition(configuration.transition)
////                            .zIndex(3)
////                    }
////                }
////                .zIndex(999)
////                .animation(configuration.animation, value: item.wrappedValue?.destination == nil)
////            )
//    }
//}
//
//extension View {
//    
////    @ViewBuilder func frame(configuration: ModalConfiguration) -> some View {
////        if configuration.useDeviceBounds {
////            frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height, alignment: configuration.alignment)
////        } else {
////            frame(maxWidth: .infinity, maxHeight: .infinity, alignment: configuration.alignment)
////        }
////    }
//    
//}
//
//
//
//
import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    // 1
    let url: URL

    
    // 2
    func makeUIView(context: Context) -> WKWebView {

        return WKWebView()
    }
    
    // 3
    func updateUIView(_ webView: WKWebView, context: Context) {

        let request = URLRequest(url: url)
        webView.load(request)
    }
}
