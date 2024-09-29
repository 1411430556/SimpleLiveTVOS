//
//  PlatformView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse
import AngelLiveTools

struct PlatformView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var navigationPath = [NavigationNode]()
    let platformViewModel = PlatformViewModel()
    @Namespace private var namespace
    @State var show = false
    @State var selectedIndex = 0
    
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                let itemWidth = Common.calcPadItemCounts(width: geometry.size.width, horizontalSizeClass: horizontalSizeClass)
                VStack {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemWidth.0), spacing: 15), count: itemWidth.1), alignment: .leading, spacing: 15) {
                            ForEach(platformViewModel.platformInfo, id: \.id) { item in
                                NavigationLink {
                                    LiveListView(searchType: item.liveType)
                                        .environment(LiveListViewModel(liveType: item.liveType))
                                        .navigationTransition(.zoom(sourceID: item.id, in: namespace))
                                        
                                } label: {
                                    ZStack {
                                        Image("platform-bg")
                                            .resizable()
                                            .blur(radius: 0.5)
                                        Image(item.bigPic)
                                            .resizable()
                                    }
                                    .cornerRadius(10)
                                    .matchedTransitionSource(id: item.id, in: namespace)
                                }

                                .transition(.moveAndOpacity)
                                .animation(.easeInOut(duration: 0.25) ,value: true)
                                .frame(height: itemWidth.0 * 0.6)
                            }
                        }

                        .padding(.leading, 20)
                        .padding(.top, 30)
                    }
                    Text("敬请期待更多平台...")
                        .foregroundStyle(.separator)
                }
            }
            .navigationTitle("平台")
            
        }
    }
}

extension AnyTransition {
    static var moveAndOpacity: AnyTransition {
        AnyTransition.opacity
    }
}

#Preview {
    PlatformView()
}
