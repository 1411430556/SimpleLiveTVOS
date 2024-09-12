//
//  RectKey.swift
//  SegmentedControl
//
//  Created by pc on 2024/9/10.
//

import SwiftUI

struct RectKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func rect(completion: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    let rect = proxy.frame(in: .scrollView(axis: .horizontal))
                    Color.clear
                        .preference(key: RectKey.self, value: rect)
                        .onPreferenceChange(RectKey.self, perform: completion)
                }
            }
    }
}

extension CGFloat {
    func interpolate(inputRange: [CGFloat], outputRange: [CGFloat]) -> CGFloat {
        guard inputRange.count > 1 || outputRange.count > 1 else { return 0.0 }
        let x = self
        let length = inputRange.count - 1
        if x <= inputRange[0] {
            return outputRange[0]
        }
        for index in 1...length {
            let x1 = inputRange[index - 1]
            let x2 = inputRange[index]
            
            let y1 = outputRange[index - 1]
            let y2 = outputRange[index]
            
            if x <= inputRange[index] {
                let y = y1 + ((y2 - y1) / (x2 - x1)) * (x - x1)
                return y
            }
        }
        return outputRange[length]
    }
}
