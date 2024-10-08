//
//  LiveListView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse
import AngelLiveTools

struct LiveListView: View {
    
    @Environment(LiveListViewModel.self) var liveListViewModel
    @State var searchType: LiveType
    @State private var showModal = false
    
    @State var tabBarScrollableState: String?
    @State var mainViewScrollableState: String?
    @State var progress: CGFloat = .zero
    var appViewModel = AngelLiveViewModel()
    @Namespace private var namespace
    
    var body: some View {
        
        @Bindable var liveListViewModel = self.liveListViewModel
        @Bindable var bindAppViewModel = appViewModel

        VStack(spacing: 0) {
            CustomTabBarView(tabs: $liveListViewModel.tabs, activeIndex: $bindAppViewModel.activeIndex, tabbarScrollableState: $tabBarScrollableState, mainViewScrollableState: $mainViewScrollableState, progress: $progress)
            GeometryReader { proxy in
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(liveListViewModel.tabs, id: \.id) { tab in
                            ListCardView()
                                .id(tab.title)
                                .containerRelativeFrame(.horizontal)
                                .environment(liveListViewModel)
                                .environment(bindAppViewModel)
                        }
                    }
                    .scrollTargetLayout()
                    .rect { rect in
                        progress = -rect.minX / proxy.size.width
                    }
                }
                .scrollPosition(id: $mainViewScrollableState)
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.paging)
                .onChange(of: mainViewScrollableState) { oldValue, newValue in
                    if let newValue, let newIndex = liveListViewModel.tabs.firstIndex(where: { $0.title == newValue }) {
                        withAnimation(.snappy) {
                            tabBarScrollableState = newValue
                            bindAppViewModel.activeIndex = newIndex
                            liveListViewModel.selectedSubListIndex = newIndex
                            Task {
                                try await liveListViewModel.getRoomList(index: newIndex)
                            }
                        }
                    }
                }
            }
//                .ignoresSafeArea() //忽略安全区会使sidebar即使在显示时，view会藏在Sidebar底部
        }
        .navigationTitle(searchType.rawValue)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            if Common.deviceType() == .iPad {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showModal.toggle()
                    }) {
                        Text("分类")
                    }
                }
            }
        }
        .sheet(isPresented: $showModal) {
            LiveMenuView(showModel: $showModal)
                .environment(liveListViewModel)
        }
    }
}



#Preview {
    LiveListView(searchType: .bilibili)
}
