//
//  SegueOption.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

public enum SegueOption: Equatable, CaseIterable, Hashable {
    case push
    case fullScreenCoverConfig(config: FullScreenCoverConfig = FullScreenCoverConfig())
    case sheetConfig(config: ResizableSheetConfig = ResizableSheetConfig())
    
    public static var fullScreenCover: Self {
        .fullScreenCoverConfig(config: FullScreenCoverConfig())
    }
    
    public static var sheet: Self {
        .sheetConfig(config: ResizableSheetConfig())
    }
    
    public static var allCases: [SegueOption] {
        [.push, .fullScreenCover, .sheet]
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(stringValue)
    }
    
    public static func == (lhs: SegueOption, rhs: SegueOption) -> Bool {
        lhs.stringValue == rhs.stringValue
    }
    
    public var codeString: String {
        switch self {
        case .push:
            return ".push"
        case .sheetConfig:
            return ".sheet"
        case .fullScreenCoverConfig:
            return ".fullScreenCover"
        }
    }
    
    public var stringValue: String {
        switch self {
        case .push:
            return "push"
        case .sheetConfig:
            return "sheet"
        case .fullScreenCoverConfig:
            return "fullScreenCover"
        }
    }
    
    public var isResizeableSheet: Bool {
        switch self {
        case .push:
            return false
        case .fullScreenCoverConfig(let config):
            return false
        case .sheetConfig(let config):
            return config.detents != [.large]
        }
    }
    
    public var presentsNewEnvironment: Bool {
        switch self {
        case .push:
            return false
        case .sheetConfig, .fullScreenCoverConfig:
            return true
        }
    }
}
