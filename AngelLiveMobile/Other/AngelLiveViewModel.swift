//
//  AngelLiveViewModel.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/25.
//

import Foundation
import Observation
import SwiftUI

@Observable
class AngelLiveViewModel {
    var activeIndex = 0
    var scrollDelegate = ScrollViewModel()
}
