//
//  SwipeBackSupportContainer.swift
//
//
//  Created by Nicholas Sarno on 2/27/24.
//

import SwiftUI

struct SwipeBackSupportContainer<Content:View>: View {
    
    var insertionTransition: TransitionOption = .trailingCover
    var swipeThreshold: CGFloat = 30
    @ViewBuilder var content: () -> Content
    var onDidSwipeBack: (() -> Void)? = nil
    
    @State private var viewOffset: CGSize = .zero
    let animation: Animation = .smooth(duration: 0.3)

    var body: some View {
        ZStack {
            content()
                .offset(viewOffset)
                .animation(animation, value: viewOffset)
            
         
            Rectangle()
                .fill(Color.red)
                .frame(width: overlayWidth, height: overlayHeight)
                .withDragGesture(
                    insertionTransition.reversed.asAxis,
                    minimumDistance: 10,
                    resets: true,
                    animation: animation,
                    onChanged: { offset in
                        if offset != .zero {
                            setViewOffset(from: offset)
                        }
                    },
                    onEnded: { _ in
                        handleDidSwipeBackIfNeeded()
                    }
                )
                .padding(.top, topPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: insertionTransition.reversed.asAlignment)
        }
    }
    
    private var topPadding: CGFloat? {
        switch insertionTransition {
        case .trailing, .trailingCover, .leading, .leadingCover:
            return 60
        case .top, .topCover, .bottom, .bottomCover:
            return nil
        }
    }
    
    private func handleDidSwipeBackIfNeeded() {
        switch insertionTransition {
        case .trailing, .trailingCover, .leading, .leadingCover:
            let horizontalOffset = abs(viewOffset.width)
            
            if horizontalOffset >= swipeThreshold {
                onDidSwipeBack?()
                
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    viewOffset = .zero
                }
            } else {
                viewOffset = .zero
            }
        case .top, .topCover, .bottom, .bottomCover:
            let verticalOffset = abs(viewOffset.height)
            
            if verticalOffset >= swipeThreshold {
                onDidSwipeBack?()
                
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    viewOffset = .zero
                }
            } else {
                viewOffset = .zero
            }
        }
    }
    
    private func setViewOffset(from offset: CGSize) {
        switch insertionTransition {
        case .trailing, .trailingCover:
            viewOffset = CGSize(width: max(offset.width, 0), height: 0)
        case .leading, .leadingCover:
            viewOffset = CGSize(width: min(offset.width, 0), height: 0)
        case .top, .topCover:
            viewOffset = CGSize(width: 0, height: min(offset.height, 0))
        case .bottom, .bottomCover:
            viewOffset = CGSize(width: 0, height: max(offset.height, 0))
        }
    }
    
    private var overlayWidth: CGFloat? {
        switch insertionTransition {
        case .trailing, .trailingCover, .leading, .leadingCover:
            return 24
        default:
            return nil
        }
    }
    
    private var overlayHeight: CGFloat? {
        switch insertionTransition {
        case .top, .topCover, .bottom, .bottomCover:
            return 30
        default:
            return nil
        }
    }
    
}

#Preview {
    SwipeBackSupportContainer(insertionTransition: .leadingCover) {
        Rectangle()
            .fill(Color.black)
    }
}

private struct DragGestureViewModifier: ViewModifier {
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1

    let axes: Axis.Set
    let minimumDistance: CGFloat
    let resets: Bool
    let animation: Animation
    let rotationMultiplier: CGFloat
    let scaleMultiplier: CGFloat
    let onChanged: ((_ dragOffset: CGSize) -> ())?
    let onEnded: ((_ dragOffset: CGSize) -> ())?

    init(
        _ axes: Axis.Set = [.horizontal, .vertical],
        minimumDistance: CGFloat = 0,
        resets: Bool,
        animation: Animation,
        rotationMultiplier: CGFloat = 0,
        scaleMultiplier: CGFloat = 0,
        onChanged: ((_ dragOffset: CGSize) -> ())?,
        onEnded: ((_ dragOffset: CGSize) -> ())?) {
            self.axes = axes
            self.minimumDistance = minimumDistance
            self.resets = resets
            self.animation = animation
            self.rotationMultiplier = rotationMultiplier
            self.scaleMultiplier = scaleMultiplier
            self.onChanged = onChanged
            self.onEnded = onEnded
        }
        
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .rotationEffect(Angle(degrees: rotation), anchor: .center)
            .offset(getOffset(offset: lastOffset))
            .offset(getOffset(offset: offset))
            .simultaneousGesture(
                DragGesture(minimumDistance: minimumDistance, coordinateSpace: .global)
                    .onChanged({ value in
                        onChanged?(value.translation)
                        
                        withAnimation(animation) {
                            offset = value.translation
                            
                            rotation = getRotation(translation: value.translation)
                            scale = getScale(translation: value.translation)
                        }
                    })
                    .onEnded({ value in
                        if !resets {
                            onEnded?(lastOffset)
                        } else {
                            onEnded?(value.translation)
                        }

                        withAnimation(animation) {
                            offset = .zero
                            rotation = 0
                            scale = 1
                            
                            if !resets {
                                lastOffset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height)
                            } else {
                                onChanged?(offset)
                            }
                        }
                    })
            )
    }
    
    
    private func getOffset(offset: CGSize) -> CGSize {
        switch axes {
        case .vertical:
            return CGSize(width: 0, height: offset.height)
        case .horizontal:
            return CGSize(width: offset.width, height: 0)
        default:
            return offset
        }
    }
    
    private func getRotation(translation: CGSize) -> CGFloat {
        let max = UIScreen.main.bounds.width / 2
        let percentage = translation.width * rotationMultiplier / max
        let maxRotation: CGFloat = 10
        return percentage * maxRotation
    }
    
    private func getScale(translation: CGSize) -> CGFloat {
        let max = UIScreen.main.bounds.width / 2
        
        var offsetAmount: CGFloat = 0
        switch axes {
        case .vertical:
            offsetAmount = abs(translation.height + lastOffset.height)
        case .horizontal:
            offsetAmount = abs(translation.width + lastOffset.width)
        default:
            offsetAmount = (abs(translation.width + lastOffset.width) + abs(translation.height + lastOffset.height)) / 2
        }
        
        let percentage = offsetAmount * scaleMultiplier / max
        let minScale: CGFloat = 0.8
        let range = 1 - minScale
        return 1 - (range * percentage)
    }
    
}

private extension View {
    
    /// Add a DragGesture to a View.
    ///
    /// DragGesture is added as a simultaneousGesture, to not interfere with other gestures Developer may add.
    ///
    /// - Parameters:
    ///   - axes: Determines the drag axes. Default allows for both horizontal and vertical movement.
    ///   - resets: If the View should reset to starting state onEnded.
    ///   - animation: The drag animation.
    ///   - rotationMultiplier: Used to rotate the View while dragging. Only applies to horizontal movement.
    ///   - scaleMultiplier: Used to scale the View while dragging.
    ///   - onEnded: The modifier will handle the View's offset onEnded. This escaping closure is for Developer convenience.
    ///
    func withDragGesture(
        _ axes: Axis.Set = [.horizontal, .vertical],
        minimumDistance: CGFloat = 0,
        resets: Bool = true,
        animation: Animation = .spring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.0),
        rotationMultiplier: CGFloat = 0,
        scaleMultiplier: CGFloat = 0,
        onChanged: ((_ dragOffset: CGSize) -> ())? = nil,
        onEnded: ((_ dragOffset: CGSize) -> ())? = nil) -> some View {
            modifier(DragGestureViewModifier(axes, minimumDistance: minimumDistance, resets: resets, animation: animation, rotationMultiplier: rotationMultiplier, scaleMultiplier: scaleMultiplier, onChanged: onChanged, onEnded: onEnded))
    }
    
}

//struct DragGestureViewModifier_Previews: PreviewProvider {
//    
//    static var previews: some View {
//        RoundedRectangle(cornerRadius: 10)
//            .frame(width: 300, height: 200)
//            .withDragGesture(
//                [.vertical, .horizontal],
//                resets: true,
//                animation: .smooth,
//                rotationMultiplier: 1.1,
//                scaleMultiplier: 1.1,
//                onChanged: { dragOffset in
//                    let tx = dragOffset.height
//                    let ty = dragOffset.width
//                },
//                onEnded: { dragOffset in
//                    let tx = dragOffset.height
//                    let ty = dragOffset.width
//                }
//            )
//    }
//}
