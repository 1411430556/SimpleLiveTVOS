//
//  ListCardView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/11.
//

import SwiftUI

struct ListCardView: View {
    
    @Environment(LiveListViewModel.self) var liveListViewModel
    
    var body: some View {
        VStack {
            ForEach(liveListViewModel.roomList, id: \.id) { item in
                Text(item.roomTitle)
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
