//
//  Array+EXT.swift
//  
//
//  Created by Nick Sarno on 9/3/23.
//

import Foundation

extension Array where Element: Equatable {
    func firstAfter(_ element: Element) -> Element? {
        if let index = self.firstIndex(of: element), index + 1 < self.count {
            return self[index + 1]
        }
        return nil
    }
    
    func firstBefore(_ element: Element) -> Element? {
        if let index = self.firstIndex(of: element), index > 0 {
            return self[index - 1]
        }
        return nil
    }
}
