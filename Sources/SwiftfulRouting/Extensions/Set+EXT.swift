//
//  Set+EXT.swift
//  
//
//  Created by Nick Sarno on 1/28/23.
//

import Foundation

extension Set {
    func setMap<U>(_ transform: (Element) -> U) -> Set<U> {
        return Set<U>(self.lazy.map(transform))
    }
}
