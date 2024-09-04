//
//  LiveListView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse

struct LiveListView: View {
    
    @State var searchType: LiveType
    
    var body: some View {
        Text("LiveListView:\(searchType)")
    }
}

#Preview {
    LiveListView(searchType: .bilibili)
}
