//
//  ListCardView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/11.
//

import SwiftUI
import Kingfisher

struct ListCardView: View {
    
    @Environment(LiveListViewModel.self) var liveListViewModel
    
    var body: some View {
        VStack {
            ForEach(liveListViewModel.roomList, id: \.id) { item in
                NavigationLink {
                    
                } label: {
                    VStack {
                        KFImage(.init(string: item.roomCover))
                            .placeholder {
                                Image("placeholder")
                                    .resizable()
                                    .cornerRadius(5)
                            }
                            .resizable()
                            .cornerRadius(5)
                            .frame(width: 180, height: 180 * 0.6)
                        Text(item.roomTitle)
                            .fontWeight(.bold)
                        Text(item.userName)
                            .fontWeight(.medium)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .onAppear {
            liveListViewModel.getRoomList(index: liveListViewModel.selectedSubListIndex)
        }
    }
}

//#Preview {
//    ListCardView()
//}
