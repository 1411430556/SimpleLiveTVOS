//
//  HomeView.swift
//  SegmentedControl
//
//  Created by pc on 2024/9/10.
//

import SwiftUI

struct HomeView: View {
    
    @State var tabs: [MyView] = [
        MyView(title: "All", theView: AnyView(Color.red)),
        MyView(title: "Romantic Comedy", theView: AnyView(Color.blue)),
        MyView(title: "Thriller", theView: AnyView(Color.brown)),
        MyView(title: "Documentary Films", theView: AnyView(Color.purple)),
        MyView(title: "Sci-Fi", theView: AnyView(Color.pink)),
        MyView(title: "Hisrotcal Dreams", theView: AnyView(Color.green)),
    ]
    
    @State var activeIndex = 0
    @State var tabBarScrollableState: String?
    @State var mainViewScrollableState: String?
    @State var progress: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            CustomTabBarView(tabs: $tabs, activeIndex: $activeIndex, tabbarScrollableState: $tabBarScrollableState, mainViewScrollableState: $mainViewScrollableState, progress: $progress)
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(tabs, id: \.id) { tab in
                            tab.theView
                                .id(tab.title)
                                .containerRelativeFrame(.horizontal)
                        }
                    }
                    .scrollTargetLayout()
                    .rect { rect in
                        progress = -rect.minX / proxy.size.width
                    }
//                    .safeAreaPadding(.top, 120)
                }
                .scrollPosition(id: $mainViewScrollableState)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
                .onChange(of: mainViewScrollableState) { oldValue, newValue in
                    if let newValue, let newIndex = tabs.firstIndex(where: { $0.title == newValue }) {
                        withAnimation(.snappy) {
                            tabBarScrollableState = newValue
                            activeIndex = newIndex
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

