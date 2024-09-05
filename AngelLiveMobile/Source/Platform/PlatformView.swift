//
//  PlatformView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse

struct PlatformView: View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var navigationPath = [NavigationNode]()
    
    let platformViewModel = PlatformViewModel()
    @FocusState var focusIndex: Int?
    @Namespace private var namespace
//    @Environment(SimpleLiveViewModel.self) var appViewModel
    @State var show = false
    @State var selectedIndex = 0
    
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in
                
                let itemWidth = (geometry.size.width - 40 - ((horizontalSizeClass == .regular ? 2 : 4) * 15)) / (horizontalSizeClass == .regular ? 3 : 5)
                
                VStack {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(itemWidth), spacing: 15), count: horizontalSizeClass == .regular ? 3 : 5), alignment: .leading, spacing: 15) {
                            ForEach(platformViewModel.platformInfo.indices, id: \.self) { index in
                                NavigationLink {
                                    LiveListView(searchType: platformViewModel.platformInfo[index].liveType)
                                } label: {
                                    ZStack {
                                        Image("platform-bg")
                                            .resizable()
                                        Image(platformViewModel.platformInfo[index].bigPic)
                                            .resizable()
                                            .animation(.easeInOut(duration: 0.25), value: focusIndex == index)
                                            .blur(radius: focusIndex == index ? 10 : 0)
                                        
                                        ZStack {
                                            Image(platformViewModel.platformInfo[index].smallPic)
                                                .resizable()
                                            Text(platformViewModel.platformInfo[index].descripiton)
                                                .font(.body)
                                                .multilineTextAlignment(.leading)
                                                .padding([.leading, .trailing], 15)
                                                .padding(.top, 50)
                                            
                                        }
                                        .background(.thinMaterial)
                                        .opacity(focusIndex == index ? 1 : 0)
                                        .animation(.easeInOut(duration: 0.25), value: focusIndex == index)
                                    }
                                }
                                .background(.red)
                                .focused($focusIndex, equals: index)
                                .transition(.moveAndOpacity)
                                .animation(.easeInOut(duration: 0.25) ,value: true)
                                .frame(height: itemWidth * 0.6)
                                
                            }
                        }
                        
                        .padding(.leading, 20)
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
