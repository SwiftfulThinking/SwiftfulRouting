////
////  PopoverOption.swift
////
////
////  Created by Nick Sarno on 8/28/23.
////
//
//import Foundation
//import SwiftUI
//
//public indirect enum PopoverOption {
//    case fullScreenCover, sheet
//    case popover()
//    case adaptive(horizontal: PopoverOption, vertical: PopoverOption)
//
//    @available(iOS 16.4, *)
//    public var attachmentAnchor: PopoverAttachmentAnchor {
//        switch self {
//        case .fullScreenCover, .sheet:
//            return .point(.bottom)
//        case .popover(let anchor):
//            return anchor
//        case .adaptive(let horizontal, let vertical):
//            let isHorizontal = UIDevice.current.orientation.isLandscape
//            if isHorizontal {
//                switch horizontal {
//                case .fullScreenCover, .sheet, .adaptive:
//                    return .point(.bottom)
//                case .popover(let anchor):
//                    return anchor
//                }
//            } else {
//                switch vertical {
//                case .fullScreenCover, .sheet, .adaptive:
//                    return .point(.bottom)
//                case .popover(let anchor):
//                    return anchor
//                }
//            }
//        }
//    }
//
//    @available(iOS 16.4, *)
//    public var horizontalAdaptation: PresentationAdaptation {
//        switch self {
//        case .fullScreenCover:
//            return .fullScreenCover
//        case .sheet:
//            return .sheet
//        case .popover:
//            return .popover
//        case .adaptive(let horizontal, _):
//            switch horizontal {
//            case .fullScreenCover:
//                return .fullScreenCover
//            case .sheet:
//                return .sheet
//            case .popover, .adaptive:
//                return .popover
//            }
//        }
//    }
//
//    @available(iOS 16.4, *)
//    public var verticalAdaptation: PresentationAdaptation {
//        switch self {
//        case .fullScreenCover:
//            return .fullScreenCover
//        case .sheet:
//            return .sheet
//        case .popover:
//            return .popover
//        case .adaptive(_, let vertical):
//            switch vertical {
//            case .fullScreenCover:
//                return .fullScreenCover
//            case .sheet:
//                return .sheet
//            case .popover, .adaptive:
//                return .popover
//            }
//        }
//    }
//}
