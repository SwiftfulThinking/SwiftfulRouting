//
//  Array+EXT.swift
//  
//
//  Created by Nick Sarno on 9/3/23.
//

import Foundation

extension Array where Element: Equatable {
    
    func firstAfter(_ element: Element, where condition: (Element) -> Bool) -> Element? {
        for (index, item) in self.enumerated() {
            if item == element && index + 1 < self.count {
                let nextIndex = index + 1
                if condition(self[nextIndex]) {
                    return self[nextIndex]
                }
            }
        }
        return nil
    }
    
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
    
    mutating func insertAfter(_ element: Element, after: Element) {
        if let index = self.firstIndex(of: after), self.count > index {
            let nextIndex = index + 1
            self.insert(element, at: nextIndex)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(element)
        }
    }
    
    mutating func insertBefore(_ element: Element, before: Element) {
        if let index = self.firstIndex(of: before) {
            self.insert(element, at: index)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(element)
        }
    }
    
    mutating func insertAfter(_ elements: [Element], after: Element) {
        if let index = self.firstIndex(of: after), (index + 1) < self.count {
            let nextIndex = index + 1
            self.insert(contentsOf: elements, at: nextIndex)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(contentsOf: elements)
        }
    }
    
    mutating func insertBefore(_ elements: [Element], before: Element) {
        if let index = self.firstIndex(of: before) {
            self.insert(contentsOf: elements, at: index)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(contentsOf: elements)
        }
    }
    
//    mutating func removeAllAfter(_ element: Element) {
//        if let index = self.firstIndex(of: element), (index + 1) < self.count {
//            let startIndex = index + 1
//            if startIndex < self.count {
//                self.removeSubrange(startIndex..<self.count)
//            }
//        }
//    }
}
