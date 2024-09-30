//
//  LiveDetailView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/27.
//

import SwiftUI
import Kingfisher
import KSPlayer

struct LiveDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(LiveDetailViewModel.self) var liveViewModel
    
    var body: some View {
        VStack {
            customNavigationBar
            HStack {
                VStack {
                    if liveViewModel.currentPlayURL != nil {
                        KSVideoPlayer(coordinator: liveViewModel.playerCoordinator, url:liveViewModel.currentPlayURL ?? URL(string: "")!, options: liveViewModel.playerOption)
                            .background(Color.black)
                            .onAppear {
                                liveViewModel.playerCoordinator.playerLayer?.play()
                                liveViewModel.setPlayerDelegate()
                            }
                            .safeAreaPadding(.all)
                            .zIndex(1)
                    }else {
                        Color.black
                    }
                    HStack(alignment: .top) {
                        KFImage(.init(string: liveViewModel.currentRoom.userHeadImg))
                            .placeholder {
                                AnyView(Color.gray)
                                    .cornerRadius(15)
                            }
                            .resizable()
                            .cornerRadius(15)
                            .frame(width: 30, height: 30)

                        VStack(alignment: .leading) {
                            Text(liveViewModel.currentRoom.roomTitle)
                                .fontWeight(.bold)
                                .lineLimit(2)
                                .lineSpacing(5)
                                .truncationMode(.tail)
                                .multilineTextAlignment(.leading)
                            Text(liveViewModel.currentRoom.userName)
                                .fontWeight(.medium)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
        .background(.black)
        .onAppear {
            liveViewModel.getPlayArgs()
        }
        
    }
    
    private var customNavigationBar: some View {
        ZStack {
            Color(.systemBackground) // 使用系统背景色
//                .shadow(color: Color.black.opacity(0.2), radius: 3)
            
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                        .padding()
                }
                
                Spacer()
                
                Spacer()
                
                Color.clear
                    .frame(width: 44, height: 44)
            }
        }
        .frame(height: 44)
    }
}

#Preview {
    LiveDetailView()
}
