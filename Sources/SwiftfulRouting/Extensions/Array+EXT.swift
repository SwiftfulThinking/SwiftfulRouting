//
//  Array+EXT.swift
//  
//
//  Created by Nick Sarno on 9/3/23.
//

import Foundation

extension Array where Element: Identifiable {
    
    func firstAfter(_ element: Element, where condition: (Element) -> Bool) -> Element? {
        var didFindElement: Bool = false
        for item in self {
            if didFindElement {
                if condition(item) {
                    return item
                }
            }
            
            if item.id == element.id {
                didFindElement = true
            }
        }
        
        return nil
    }
    
    func firstAfter(_ element: Element) -> Element? {
        if let index = self.firstIndex(where: { $0.id == element.id }), index + 1 < self.count {
            return self[index + 1]
        }
        return nil
    }
    
    func firstBefore(_ element: Element) -> Element? {
        if let index = self.firstIndex(where: { $0.id == element.id }), index > 0 {
            return self[index - 1]
        }
        return nil
    }
    
    mutating func insertAfter(_ element: Element, after: Element) {
        if let index = self.firstIndex(where: { $0.id == after.id }), self.count > index {
            let nextIndex = index + 1
            self.insert(element, at: nextIndex)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(element)
        }
    }
    
    mutating func insertBefore(_ element: Element, before: Element) {
        if let index = self.firstIndex(where: { $0.id == before.id }) {
            self.insert(element, at: index)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(element)
        }
    }
    
    mutating func insertAfter(_ elements: [Element], after: Element) {
        if let index = self.firstIndex(where: { $0.id == after.id }), (index + 1) < self.count {
            let nextIndex = index + 1
            self.insert(contentsOf: elements, at: nextIndex)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(contentsOf: elements)
        }
    }
    
    mutating func insertBefore(_ elements: [Element], before: Element) {
        if let index = self.firstIndex(where: { $0.id == before.id }) {
            self.insert(contentsOf: elements, at: index)
        } else {
            // If the element is not found, append the new element at the end.
            self.append(contentsOf: elements)
        }
    }
    
    func allAfter(_ element: Element) -> [Element]? {
        guard let index = self.firstIndex(where: { $0.id == element.id }), index < self.count - 1 else {
            return nil
        }
        return Array(self[(index + 1)...])
    }
    
    func allBefore(_ element: Element) -> [Element]? {
        guard let index = self.firstIndex(where: { $0.id == element.id }), index > 0 else {
            return nil
        }
        return Array(self[..<index])
    }
    
}

extension Array where Element: Collection, Element.Element: Identifiable {
    mutating func removeArraysAfter(arrayThatIncludesId id: Element.Element.ID) {
        if let index = self.firstIndex(where: { $0.contains(where: { $0.id == id }) }) {
            self = Array(self.prefix(upTo: index + 1))
        }
    }
}
