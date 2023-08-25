//
//  UrlOption.swift
//  
//
//  Created by Nick Sarno on 8/24/23.
//

import Foundation

public enum UrlOption: Equatable {
    case inAppBrowser(segue: SegueOption)
    case safari, urlSchema
}
