//
//  AngelLiveTabView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse

@available(iOS 18.0, *)
struct AngelLiveTabView: View {
    
    @AppStorage("Angel.Live.TabView.Customization") var tabViewCustomization: TabViewCustomization
    @State private var allPlatformList = LiveParseTools.getAllSupportPlatform()
    @State private var selectedTab: Tabs = .favorite
    
    var body: some View {
        VStack {
            TabView {
                Tab("收藏", systemImage: "play") {
                    FavoriteView()
                }
                .customizationID(Tabs.favorite.customizationID)
                if UIDevice.current.userInterfaceIdiom == .phone {
                    Tab("平台", systemImage: "play") {
                        PlatformView()
                    }
                    .customizationID(Tabs.platform.customizationID)
                }else {
                    TabSection(content: {
                        Tab("平台", systemImage: "play") {
                            PlatformView()
                        }
                        .customizationID(Tabs.platform.customizationID)
                        .customizationBehavior(.reorderable, for: .tabBar)
                        ForEach(allPlatformList.indices, id: \.self) { index in
                            Tab(LiveParseTools.getLivePlatformName(allPlatformList[index].liveType), systemImage: "books.vertical") {
                                LiveListView(searchType: allPlatformList[index].liveType)
                            }
                            .customizationBehavior(.reorderable, for: .sidebar)
                        }
                    }, header: {
                        Label("平台", image: "list.bullet.rectangle")
                    })
                }
                
                Tab("设置", systemImage: "books.vertical") {
                    SettingView()
                }
                .customizationID(Tabs.setting.customizationID)
                Tab(role: .search) {
                    SearchView()
                }
                .customizationID(Tabs.search.customizationID)
            }
            .tabViewCustomization($tabViewCustomization)
            .tabViewStyle(.sidebarAdaptable)
            .navigationTitle("Angel Live")
            .toolbar {
                Button {
                    
                } label: {
                    Text("Add")
                }
            }
        }
    }
}

#Preview {
    if #available(iOS 18.0, *) {
        AngelLiveTabView()
    } else {
        // Fallback on earlier versions
    }
}
