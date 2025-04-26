//
//  UserDefaults+EXT.swift
//  SwiftfulRouting
//
//  Created by Nick Sarno on 4/19/25.
//
import Foundation

public extension UserDefaults {
    
    @MainActor
    static var lastModuleId: String {
        get {
            standard.string(forKey: "last_module_id") ?? RouterViewModel.rootId
        }
        set {
            standard.set(newValue, forKey: "last_module_id")
        }
    }
}
