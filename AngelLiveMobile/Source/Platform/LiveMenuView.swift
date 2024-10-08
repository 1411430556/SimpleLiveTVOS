//
//  LiveMenuView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/10/8.
//

import SwiftUI
import Kingfisher
import AngelLiveTools

struct LiveMenuView: View {
    @Binding var showModel: Bool
    @State private var searchText = ""
    @Environment(LiveListViewModel.self) var liveListViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            SearchBar(text: $searchText)
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(100), spacing: 15), count: 6), alignment: .leading, spacing: 15) {
                ForEach(liveListViewModel.categories.indices, id: \.self) { index in
                    Button {
                        liveListViewModel.showSubCategoryList(currentCategory: liveListViewModel.categories[index])
                        showModel.toggle()
                    } label: {
                        VStack {
                            if liveListViewModel.categories[index].icon.isEmpty {
                                Image(Common.getImage(liveListViewModel.liveType))
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            }else {
                                KFImage(.init(string: liveListViewModel.categories[index].icon))
                                    .resizable()
                                    .frame(width: 80, height: 80)
                            }
                            Text(liveListViewModel.categories[index].title)
                        }
                    }
                }
                .padding(.leading, 10)
            }
            Spacer()
            Button(action: {
                showModel.toggle()
            }) {
                Text("关闭")
            }
        }
        .padding()
    }
}

#Preview {
    LiveMenuView(showModel: .constant(true))
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            TextField("Search", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
        }
        .padding(.horizontal, 10)
    }
}
