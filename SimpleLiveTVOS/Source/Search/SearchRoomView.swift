//
//  SearchRoomView.swift
//  SimpleLiveTVOS
//
//  Created by pangchong on 2023/11/30.
//

import SwiftUI
import SimpleToast
import LiveParse
import Shimmer

struct SearchRoomView: View {
    
    @FocusState var focusState: Int?
    @Environment(LiveViewModel.self) var liveViewModel
    @Environment(SimpleLiveViewModel.self) var appViewModel
    
    var body: some View {
        
        @Bindable var appModel = appViewModel
        @Bindable var liveModel = liveViewModel
        
        VStack {
            Text("请输入要搜索的主播名或平台链接/分享口令/房间号")
            HStack {
                Menu {
                    ForEach(liveViewModel.searchTypeArray.indices, id: \.self) { index in
                        Button {
                            appModel.searchModel.searchTypeIndex = index
                        } label: {
                            let text = liveViewModel.searchTypeArray[index]
                            Text(text)
                        }
                    }

                } label: {
                    Text(liveViewModel.searchTypeArray[appModel.searchModel.searchTypeIndex])
                }
                
                TextField("搜索", text: $appModel.searchModel.searchText)
                    .onSubmit {
                        if appModel.searchModel.searchTypeIndex == 0 {
                            liveViewModel.roomPage = 1
                            Task {
                                await liveViewModel.searchRoomWithText(text: appModel.searchModel.searchText)
                            }
                        }else {
                            liveViewModel.roomPage = 1
                            liveViewModel.searchRoomWithShareCode(text: appModel.searchModel.searchText)
                        }
                        
                    }
            }
            Spacer()
            if appModel.searchModel.searchTypeIndex == 0 && liveViewModel.roomList.count == 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("提示:")
                            .font(.title3)
                        Text("搜索结果可能不全，如搜索无结果请尝试”链接/分享口令/房间号“选项")
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }else if appModel.searchModel.searchTypeIndex == 1 && liveViewModel.roomList.count == 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("支持格式:")
                            .font(.title3)
                        Text("B站：【暖雪玩玩-哔哩哔哩直播】 https://b23.tv/jeBazlm || https://live.bilibili.com/404 || 404")
                            .font(.callout)
                        Text("Douyu: https://www.douyu.com/7180846 || 7180846 || https://www.douyu.com/lpl")
                            .font(.callout)
                        Text("Huya: 霸哥(房间号189201)正在直播\"冠军园区！大师局9999目前3170\" 分享自 @虎牙直播https://m.huya.com/189201?shareid=16890536033617446582&shareUid=13794774&source=ios&pid=1724691&liveid=7312248923907638255&platform=7&from=cpy&invite_code=HY76QLTk || https://www.huya.com/660000 || 660000 || https://www.huya.com/lpl")
                            .font(.callout)
                        Text("Douyin: 2- #在抖音，记录美好生活#【交个朋友直播间】正在直播，来和我一起支持Ta吧。复制下方链接，打开【抖音】，直接观看直播！ https://v.douyin.com/i8rhQQ2t/ 2@4.com 12/18 || https://live.douyin.com/168465302284 || 168465302284")
                            .font(.callout)
                        Text("网易CC: https://cc.163.com/364038534/ || 364038534")
                            .font(.callout)
                        Text("快手：https://live.kuaishou.com/u/Boy333ks1203 || Boy333ks1203")
                            .font(.callout)
                        Text("YY: 1雪儿7156正在YY直播【她正在唱歌】，上YY 陪你一起唱！ 丫 https://www.yy.com/share/i/v2?platform=5&config_id=55&edition=1&sharedOid=5e9b07f01bcb028e927bf7932f74bc1b&userUid=a5a06fc73370b2af419dbe7f81ca540a&sid=87208093&ssid=87208093&timestamp=1718161221&version=8.40.0 丫，复制此消息，打开【YY直播】，直接观看！| https://www.yy.com/54880976/54880976?tempId=16777217 | 54880976")
                            .font(.callout)
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }else if appModel.searchModel.searchTypeIndex == 2 && liveViewModel.roomList.count == 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("可选格式:")
                            .font(.title3)
                        Text("https://www.youtube.com/watch?v=36YnV9STBqc")
                            .font(.headline)
                        Text("https://www.youtube.com/live/36YnV9STBqc")
                            .font(.headline)
                        Text("36YnV9STBqc")
                            .font(.headline)
                        Spacer()
                    }
                    .foregroundStyle(.secondary)
                    Spacer()
                }
            }else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.fixed(370), spacing: 50), GridItem(.fixed(370), spacing: 50), GridItem(.fixed(370), spacing: 50), GridItem(.fixed(370), spacing: 50)], spacing: 50) {
                        ForEach(liveViewModel.roomList.indices, id: \.self) { index in
                            LiveCardView(index: index)
                                .environment(liveViewModel)
                                .frame(width: 370, height: 280)
                        }
                        if liveViewModel.isLoading {
                            LoadingView()
                                .frame(width: 370, height: 280)
                                .cornerRadius(5)
                                .shimmering(active: true)
                                .redacted(reason: .placeholder)
                        }
                    }
                    .safeAreaPadding(.top, 50)
                }
            }
        }
        .simpleToast(isPresented: $liveModel.showToast, options: liveModel.toastOptions) {
            VStack(alignment: .leading) {
                Label("提示", systemImage: liveModel.toastTypeIsSuccess ? "checkmark.circle" : "xmark.circle")
                    .font(.headline.bold())
                Text(liveModel.toastTitle)
            }
            .padding()
            .background(.black.opacity(0.6))
            .foregroundColor(Color.white)
            .cornerRadius(10)
        }
        .onPlayPauseCommand(perform: {
            liveViewModel.getRoomList(index: 1)
        })
    }
}

