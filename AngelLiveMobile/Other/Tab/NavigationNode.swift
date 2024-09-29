//
//  NavigationNode.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/5.
//

import Foundation

enum NavigationNode: Equatable, Hashable, Identifiable {
    case platform(String)
    case list(String)
    case detail(String)
    
    var id: String {
        switch self {
            case .platform(let id): id
            case .list(let id): id
            case .detail(let id): id
        }
    }
}
