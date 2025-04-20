//
//  RoutingLogger.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation
import SwiftUI

@MainActor var logger: (any RoutingLogger) = MockRoutingLogger(logLevel: .warning, printParameters: false)

@MainActor
public protocol RoutingLogger {
    func trackEvent(event: RoutingLogEvent)
}

struct SwiftfulRoutingLogger {
    
    // RoutingLogger.enableLogging(logger: logger)
    @MainActor static public func set(logger newValue: RoutingLogger) {
        logger = newValue
    }

    // RoutingLogger.enableLogging(level: .info)
    @MainActor static public func set(level newValue: RoutingLogType, printParameters: Bool = false) {
        logger = MockRoutingLogger(logLevel: newValue, printParameters: printParameters)
    }
    
}

struct MockRoutingLogger: RoutingLogger {
    
    var logLevel: RoutingLogType
    var printParameters: Bool
    
    func trackEvent(event: any RoutingLogEvent) {
        #if DEBUG
        if event.type.rawValue >= logLevel.rawValue {
            var value = "\(event.type.emoji) \(event.eventName)"
            
            if printParameters, let params = event.parameters, !params.isEmpty {
                let sortedKeys = params.keys.sorted()
                for key in sortedKeys {
                    if let paramValue = params[key] {
                        value += "\n  (key: \"\(key)\", value: \(paramValue))"
                    }
                }
            }

            print(value)
        }
        #endif
    }
    
}

@MainActor
public protocol RoutingLogEvent {
    var eventName: String { get }
    var parameters: [String: Any]? { get }
    var type: RoutingLogType { get }
}

public enum RoutingLogType: Int, CaseIterable, Sendable {
    case info // 0
    case analytic // 1
    case warning // 2
    case severe // 3

    var emoji: String {
        switch self {
        case .info:
            return "👋"
        case .analytic:
            return "📈"
        case .warning:
            return "⚠️"
        case .severe:
            return "🚨"
        }
    }

    var asString: String {
        switch self {
        case .info: return "info"
        case .analytic: return "analytic"
        case .warning: return "warning"
        case .severe: return "severe"
        }
    }
}
