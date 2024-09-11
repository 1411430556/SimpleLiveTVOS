//
//  LiveListView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse

struct LiveListView: View {
    
    @Environment(LiveListViewModel.self) var liveListViewModel
    @State private var navigationPath = [NavigationNode]()
    @State var searchType: LiveType
    @State private var showModal = false
    
    @State var activeIndex = 0
    @State var tabBarScrollableState: String?
    @State var mainViewScrollableState: String?
    @State var progress: CGFloat = .zero
    
    var body: some View {
        
        @Bindable var liveListViewModel = self.liveListViewModel

        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                CustomTabBarView(tabs: $liveListViewModel.tabs, activeIndex: $activeIndex, tabbarScrollableState: $tabBarScrollableState, mainViewScrollableState: $mainViewScrollableState, progress: $progress)
                GeometryReader { proxy in
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ForEach(liveListViewModel.tabs, id: \.id) { tab in
//                                tab.theView
                                ListCardView()
                                    .id(tab.title)
                                    .containerRelativeFrame(.horizontal)
                                    .background(Color.red)
                                    .environment(liveListViewModel)
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
                        if let newValue, let newIndex = liveListViewModel.tabs.firstIndex(where: { $0.title == newValue }) {
                            withAnimation(.snappy) {
                                tabBarScrollableState = newValue
                                activeIndex = newIndex
                            }
                        }
                    }
                }
                .ignoresSafeArea()
            }
            .navigationTitle(searchType.rawValue)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showModal.toggle()
                    }) {
                        Text("分类")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                }
            }
            .sheet(isPresented: $showModal) {
                ModalView(showModel: $showModal)
            }
        }
        
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
        }
        .padding(.horizontal, 10)
    }
}

struct ModalView: View {
    
    @Binding var showModel: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Text("This is a modal view")
                .font(.title)
            SearchBar(text: $searchText)
            Spacer()
            Button(action: {
                showModel.toggle()
            }) {
                Text("Dismiss")
            }
        }
        .padding()
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(radius: 10)
    }
}

#Preview {
    LiveListView(searchType: .bilibili)
}
