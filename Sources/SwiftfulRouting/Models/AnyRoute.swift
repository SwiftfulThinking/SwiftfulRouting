//
//  File.swift
//  
//
//  Created by Nick Sarno on 1/15/24.
//

import Foundation
import SwiftUI

public struct AnyRoute: Identifiable, Hashable {
    public let id = UUID().uuidString
    public var segue: SegueOption
    public var onDismiss: (() -> Void)?
    public var destination: (AnyRouter) -> any View
    public var isPresented: Bool = false
    
    public init(_ segue: SegueOption, onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> any View) {
        self.segue = segue
        self.onDismiss = onDismiss
        self.destination = destination
    }
    
    static var root: AnyRoute = {
        var route = AnyRoute(.push) { router in
            AnyView(Text("Root"))
        }
        return route
    }()
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id + isPresented.description)
    }
    
    public static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

/// PushRoute is AnyRoute where segue == .push
/// This is used for pushing multiple view at once onto the NavigationStack, which only allows for .push
public struct PushRoute: Identifiable {    
    public let id = UUID().uuidString
    let segue: SegueOption = .push
    let onDismiss: (() -> Void)?
    let destination: (AnyRouter) -> any View
    
    public init(onDismiss: (() -> Void)? = nil, destination: @escaping (AnyRouter) -> any View) {
        self.onDismiss = onDismiss
        self.destination = destination
    }
    
    var asAnyRoute: AnyRoute {
        AnyRoute(segue, onDismiss: onDismiss, destination: destination)
    }
}
