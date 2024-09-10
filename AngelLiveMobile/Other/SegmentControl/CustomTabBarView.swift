//
//  CustomTabBarView.swift
//  SegmentedControl
//
//  Created by pc on 2024/9/10.
//

import SwiftUI

struct CustomTabBarView: View {
    
    @Binding var tabs: [MyView]
    @Binding var activeIndex: Int
    @Binding var tabbarScrollableState: String?
    @Binding var mainViewScrollableState: String?
    @Binding var progress: CGFloat
    @State var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                ZStack {
                    TabBarScrollView(tabs: $tabs, activeIndex: $activeIndex, tabBarScrollableState: $tabbarScrollableState, mainViewScrollableState: $mainViewScrollableState, textColor: .gray, proxy: proxy)
                        .mask {
                            TabIndicatorView(tabs: tabs, progress: progress, scrollOffset: $scrollOffset)
                        }
                    
                    TabBarScrollView(tabs: $tabs, activeIndex: $activeIndex, tabBarScrollableState: $tabbarScrollableState, mainViewScrollableState: $mainViewScrollableState, textColor: .gray, proxy: proxy)
                }
            }
            .onScrollGeometryChange(for: CGFloat.self, of: { geo in
                return geo.contentOffset.x + geo.contentInsets.leading
            }, action: { new, old in
                scrollOffset = new
            })
        }
        .scrollPosition(id: .init(get: {
            return tabbarScrollableState
        }, set: { _ in
            
        }), anchor: .center)
        .background(alignment: .bottom) {
            TabIndicatorView(tabs: tabs, progress: progress, scrollOffset: $scrollOffset)
        }
        .safeAreaPadding(.horizontal , 15)
        .scrollIndicators(.hidden)
        .padding(.bottom)
        .background(.thinMaterial)
    }
}

struct TabIndicatorView: View {
    let tabs: [MyView]
    let progress: CGFloat
    @Binding var scrollOffset: CGFloat
    var body: some View {
        ZStack {
            let inputRange = tabs.indices.map { CGFloat($0) }
            let outputRange = tabs.map { $0.size.width }
            let outputPositionRange = tabs.map { $0.minX }
            let indicatorWidth = progress.interpolate(inputRange: inputRange, outputRange: outputRange)
            let indicatorPosition = progress.interpolate(inputRange: inputRange, outputRange: outputPositionRange)
        
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.thinMaterial)
                .frame(width: indicatorWidth + 20, height: 43)
                .offset(x: indicatorPosition - 10 - scrollOffset)
                .frame(maxWidth: .infinity, alignment: .leading)
                .shadow(color: .black.opacity(0.15), radius: 2)
        }
    }
}






