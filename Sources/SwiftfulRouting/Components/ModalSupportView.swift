//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/19/24.
//
import Foundation
import SwiftUI
import SwiftfulRecursiveUI

struct ModalSupportView: View {
    
    static let backgroundAnimationDuration: Double = 0.3
    static let backgroundAnimationCurve: Animation = .easeInOut
    static let backgroundAnimation: Animation = .easeInOut(duration: 0.3)

    let modals: [AnyModal]
    let onDismissModal: (AnyModal) -> Void

    var body: some View {
        ZStack {
            LazyZStack(allowSimultaneous: true, selection: nil, items: modals) { (modal: AnyModal) in
                let dataIndex: Double = Double(modals.firstIndex(where: { $0.id == modal.id }) ?? 99)
                
                return LazyZStack(allowSimultaneous: true, selection: true) { (showView1: Bool) in
                    if showView1 {
                        modal.destination
                            .modalFrame(ignoreSafeArea: modal.ignoreSafeArea, alignment: modal.alignment)
                            .transition(modal.transition.animation(modal.animation))
                            .zIndex(dataIndex + 2)
                    } else {
                        if modal.hasBackgroundLayer {
                            Group {
                                if let backgroundColor = modal.backgroundColor {
                                    backgroundColor
                                }
                                if let backgroundEffect = modal.backgroundEffect {
                                    UIIntensityVisualEffectViewRepresentable(effect: backgroundEffect.effect, intensity: backgroundEffect.intensity)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea()
                            .transition(AnyTransition.opacity.animation(ModalSupportView.backgroundAnimation))
                            
                            // Only add backgound tap gesture if needed
                            .ifSatisfiesCondition(modal.dismissOnBackgroundTap, transform: { content in
                                content
                                    .onTapGesture {
                                        onDismissModal(modal)
                                    }
                            })
                            .zIndex(dataIndex + 1)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
            .animation(modals.last?.animation ?? .default, value: (modals.last?.id ?? "") + "\(modals.count)")
        }
    }

}

fileprivate extension View {
    
    @ViewBuilder
    func modalFrame(ignoreSafeArea: Bool, alignment: Alignment) -> some View {
        if ignoreSafeArea {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                .ignoresSafeArea()
        } else {
            self
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
        }
    }
    
}
