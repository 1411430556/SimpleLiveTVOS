//
//  RefreshableScrollView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/14.
//

import SwiftUI
import AngelLiveTools

struct RefreshableScrollView<Content: View>: View {
    @State private var isRefreshing = false
    @State private var isLoadingMore = false
    @State private var contentHeight: CGFloat = 0
    @State private var scrollViewHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    
    let content: Content
    let onRefresh: () async -> Void
    let onLoadMore: () async -> Void
    
    init(@ViewBuilder content: @escaping () -> Content, onRefresh: @escaping () async -> Void, onLoadMore: @escaping () async -> Void) {
        self.content = content()
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
    }
    
    var body: some View {
        GeometryReader { outerGeometry in
            ScrollView {
                ZStack(alignment: .top) {
                    MovingView()
                        .offset(y: isRefreshing ? 0 : -70)
                    
                    VStack {
                        content
                            .background(GeometryReader { innerGeometry in
                                Color.clear.preference(key: ContentSizePreferenceKey.self, value: innerGeometry.size.height)
                            })
                        
                        if isLoadingMore {
                            ProgressView()
                                .padding()
                        }
                    }
                }
                .offset(y: isRefreshing ? 50 : 0)
            }
            .background(GeometryReader { geometry in
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scrollView")).origin.y)
            })
            .onPreferenceChange(ContentSizePreferenceKey.self) { contentHeight in
                self.contentHeight = contentHeight
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                
                print(offset)
                self.scrollOffset = offset
                self.scrollViewHeight = outerGeometry.size.height
                
                if -offset > contentHeight - scrollViewHeight + 50 && !isLoadingMore {
                    isLoadingMore = true
                    Task {
                        await onLoadMore()
                        isLoadingMore = false
                    }
                }
                
                if offset > 50 && !isRefreshing {
                    isRefreshing = true
                    Task {
                        await onRefresh()
                        isRefreshing = false
                    }
                }
            }
        }
        .coordinateSpace(name: "scrollView")
    }
}

struct MovingView: View {
    var body: some View {
        GeometryReader { geometry in
            if geometry.frame(in: .global).minY <= 0 {
                Color.clear.frame(height: 0)
            } else {
                Color.clear.frame(height: geometry.frame(in: .global).minY)
                    .clipped()
                    .overlay(
                        ProgressView()
                            .frame(width: geometry.size.width, height: geometry.frame(in: .global).minY)
                    )
            }
        }.frame(height: 0)
    }
}

struct ContentSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
