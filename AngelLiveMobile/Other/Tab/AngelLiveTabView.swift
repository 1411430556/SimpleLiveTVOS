//
//  AngelLiveTabView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse
import AngelLiveTools

@available(iOS 18.0, *)
struct AngelLiveTabView: View {
    
    @AppStorage("Angel.Live.TabView.Customization") var tabViewCustomization: TabViewCustomization
    @State private var allPlatformList = LiveParseTools.getAllSupportPlatform()
    @State private var selectedTab: Tabs = .favorite
    @State private var navigationPath = [NavigationNode]()
    
    var body: some View {
        TabView {
            Tab("收藏", systemImage: "play") {
                FavoriteView()
                    
            }
            .customizationID(Tabs.favorite.customizationID)
            
            if Common.deviceType() == .iPad {
                TabSection {
                    ForEach(allPlatformList.indices, id: \.self) { index in
                        Tab(LiveParseTools.getLivePlatformName(allPlatformList[index].liveType), systemImage: "books.vertical") {
                            NavigationStack(path: $navigationPath) {
                                LiveListView(searchType: allPlatformList[index].liveType)
                                    .environment(LiveListViewModel(liveType: allPlatformList[index].liveType))
                            }
                        }
                        .customizationID(Tabs.platformSection(allPlatformList[index].liveType.rawValue).customizationID)
                    }
                } header: {
                    Label("平台", image: "list.bullet.rectangle")
                }
            }else {
                Tab("平台", systemImage: "play") {
                    PlatformView()
                }
                .customizationID(Tabs.platform.customizationID)
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
        .toolbar {
            Button {
                
            } label: {
                Text("Add")
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
