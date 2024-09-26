//
//  ContentView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/3.
//

import SwiftUI
import SwiftData
import LiveParse

struct ContentView: View {
    
    var body: some View {
        if #available(iOS 18.0, *) {
            AngelLiveTabView()
                .toolbarBackground(.red, for: .tabBar)
        } else {
            TabView {
                
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
