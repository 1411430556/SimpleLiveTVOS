//
//  NavigationNode.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/5.
//

import Foundation

enum NavigationNode: Equatable, Hashable, Identifiable {
    case platform(Int)
    case list(Int)
    
    var id: Int {
        switch self {
        case .platform(let id): id
        case .list(let id): id
        }
    }
}
