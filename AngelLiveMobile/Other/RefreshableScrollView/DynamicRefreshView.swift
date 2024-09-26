//
//  DynamicRefreshView.swift
//  DynamicIslandPullToRefresh
//
//  Created by pc on 2024/9/25.
//

import SwiftUI
import Observation
import AngelLiveTools


struct DynamicRefreshView<Content: View>: View {

    var content: Content
    var showsIndicator: Bool
    var dynamicTopOffset: CGFloat
    var onRefresh: () async throws -> Void
    var onLoadMore: () async throws -> Void
    
    @Environment(AngelLiveViewModel.self) var appViewModel
    
    init(content: @escaping () -> Content, showsIndicator: Bool, dynamicTopOffset: CGFloat, onRefresh: @escaping () async throws -> Void, onLoadMore: @escaping () async throws -> Void) {
        self.content = content()
        self.showsIndicator = showsIndicator
        self.dynamicTopOffset = dynamicTopOffset
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
    }
    
    var body: some View {
        
        @Bindable var bindScrollDelegate = appViewModel.scrollDelegate
        
        ScrollView(.vertical, showsIndicators: showsIndicator) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 50 * appViewModel.scrollDelegate.progress)
                content
                Rectangle()
                .fill(.black)
                .frame(height: 50)
                .opacity(appViewModel.scrollDelegate.loadMore ? 1 : 0)
            }
            .offset(coordinateSpace: "SCROLL") { offset in
                print(offset)
                print(appViewModel.scrollDelegate.contentHeight)
                appViewModel.scrollDelegate.contentOffset = offset
                if !appViewModel.scrollDelegate.isEligible {
                    var progress = offset / 50
                    progress = (progress < 0 ? 0 : progress)
                    progress = (progress > 1 ? 1 : progress)
                    appViewModel.scrollDelegate.scrollOffset = offset
                    appViewModel.scrollDelegate.progress = progress
                }
                
                if appViewModel.scrollDelegate.contentHeight < abs(offset) + CGFloat(100) && appViewModel.scrollDelegate.contentHeight > 0 {
                    appViewModel.scrollDelegate.loadMore = true
                }
                
                if appViewModel.scrollDelegate.isEligible && appViewModel.scrollDelegate.isRefreshing == false {
                    appViewModel.scrollDelegate.isRefreshing = true
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
            .contentHeight(coordinateSpace: "SCROLL") { height in
                appViewModel.scrollDelegate.contentHeight = height
            }
            
        }
       
        .overlay(alignment: .top) {
            ZStack {
                Capsule()
                    .fill(.clear)
            }
            .frame(width: 126, height: 37)
            .offset(y: dynamicTopOffset)
            .frame(maxHeight: .infinity, alignment: .top)
//            .overlay(alignment: .top) {
////                Canvas { context, size in
////                    context.addFilter(.alphaThreshold(min: 0.5, color: .black))
////                    context.addFilter(.blur(radius: 10))
////
////                    context.drawLayer { ctx in
////                        for index in [1, 2] {
////                            if let reslovedView = context.resolveSymbol(id: index) {
////                                ctx.draw(reslovedView, at: CGPoint(x: size.width / 2, y: -19))
////                            }
////                        }
////                    }
////                } symbols: {
////                    CanvasSymbol()
////                        .tag(1)
////                    CanvasSymbol(isCircle: true)
////                        .tag(2)
////                }
////                .allowsHitTesting(false)
//                Color.black
//            }
            .overlay(alignment: .top) {
                refreshView()
                    .offset(y: dynamicTopOffset)
                    
            }
            .ignoresSafeArea()
        }
        .coordinateSpace(name: "SCROLL")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                appViewModel.scrollDelegate.addGesture()
            })
        }
        .onDisappear {
            appViewModel.scrollDelegate.removeGesture()
        }
        .onChange(of: appViewModel.scrollDelegate.isRefreshing) { oldValue, newValue in
            if newValue {
                Task {
                    try await onRefresh()
                    withAnimation(.easeOut(duration: 0.25)) {
                        appViewModel.scrollDelegate.progress = 0
                        appViewModel.scrollDelegate.isEligible = false
                        appViewModel.scrollDelegate.isRefreshing = false
                        appViewModel.scrollDelegate.scrollOffset = 0
                    }
                }
            }
        }
        .onChange(of: appViewModel.scrollDelegate.loadMore) { oldValue, newValue in
            if newValue {
                Task {
                    try await onLoadMore()
                    withAnimation(.easeOut(duration: 0.25)) {
                        appViewModel.scrollDelegate.loadMore = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func CanvasSymbol(isCircle: Bool = false) -> some View {
        if isCircle {
            let centerOffset = appViewModel.scrollDelegate.isEligible ? (appViewModel.scrollDelegate.contentOffset > 19 ? appViewModel.scrollDelegate.contentOffset : 19) : appViewModel.scrollDelegate.scrollOffset
            let offset = appViewModel.scrollDelegate.scrollOffset > 0 ? centerOffset : 0
            Circle()
                .fill(.black)
                .frame(width: 37, height: 37)
                .offset(y: offset)
        }else {
            Capsule()
                .fill(.black)
                .frame(width: 126, height: 37)
        }
        
    }
    
    @ViewBuilder
    func refreshView() -> some View {
        let centerOffset = appViewModel.scrollDelegate.isEligible ? (appViewModel.scrollDelegate.contentOffset > 19 ? appViewModel.scrollDelegate.contentOffset : 19) : appViewModel.scrollDelegate.scrollOffset
        let offset = appViewModel.scrollDelegate.scrollOffset > 0 ? centerOffset : 0
        ZStack {
            Image(systemName: "arrow.down")
                .font(.caption.bold())
                .frame(width: 37, height: 37)
                .rotationEffect(.init(degrees: appViewModel.scrollDelegate.progress * 180))
                .opacity(appViewModel.scrollDelegate.isEligible ? 0 : 1)
                .background(.separator)
                .cornerRadius(37 / 2)
            ProgressView()
                .frame(width: 37, height: 37)
                .opacity(appViewModel.scrollDelegate.isEligible ? 1 : 0)
        }
        .foregroundStyle(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.25), value: appViewModel.scrollDelegate.isEligible)
        .opacity(appViewModel.scrollDelegate.progress)
        .offset(y: offset)
    }
}

// MARK: For Simultanous Pan Gesture
@Observable class ScrollViewModel: NSObject, UIGestureRecognizerDelegate {
    var id = UUID()
    var isEligible = false
    var isRefreshing = false
    var scrollOffset = 0.0
    var contentOffset = 0.0
    var contentHeight = 0.0
    var progress = 0.0
    var loadMore = false
    let gestureID = UUID().uuidString
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onGestureChange))
        panGesture.delegate = self
        panGesture.name = gestureID
        rootViewController().view.addGestureRecognizer(panGesture)
    }
    
    func removeGesture() {
        rootViewController().view.gestureRecognizers?.removeAll()
//        rootViewController().view.gestureRecognizers?.removeAll(where: { gesture in
//            gesture.name == gestureID
//        })
    }
    
    func rootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
    @objc func onGestureChange(gr: UIPanGestureRecognizer) {
        if gr.state == .cancelled || gr.state == .ended {
            if isRefreshing == false {
                if scrollOffset > 50 {
                    isEligible = true
                }else {
                    isEligible = false
                }
            }
        }
    }
}

//MARK: Offset Modifier
extension View {
    @ViewBuilder
    func offset(coordinateSpace: String, offset: @escaping (CGFloat)-> Void) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    let minY = proxy.frame(in: .named(coordinateSpace)).minY
                    Color.clear
                        .preference(key: OffsetKey.self, value: minY)
                        .onPreferenceChange(OffsetKey.self) { newValue in
                            offset(newValue)
                        }
                }
            }
    }
    
    @ViewBuilder
    func contentHeight(coordinateSpace: String, offset: @escaping (CGFloat)-> Void) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    let height = proxy.size.height - UIScreen.main.bounds.height
                    Color.clear
                        .preference(key: ContentHeightPreferenceKey.self, value: height)
                        .onPreferenceChange(ContentHeightPreferenceKey.self) { newValue in
                            offset(newValue)
                        }
                }
            }
    }
}

//MARK: Offset PreferenceKey
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ContentHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
