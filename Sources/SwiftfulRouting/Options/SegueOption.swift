//
//  SegueOption.swift
//  
//
//  Created by Nick Sarno on 5/1/22.
//

import Foundation

public enum SegueOption: Equatable {
    case push, sheet
    
    @available(iOS 14.0, *)
    case fullScreenCover
    
    @available(iOS 16.0, *)
    case sheetDetents
}
