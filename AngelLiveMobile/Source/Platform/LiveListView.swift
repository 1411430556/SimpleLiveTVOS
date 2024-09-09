//
//  LiveListView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse

struct LiveListView: View {
    
    @Environment(LiveListViewModel.self) var liveListViewModel
    @State private var navigationPath = [NavigationNode]()
    @State var searchType: LiveType
    @State private var showModal = false
    
    var body: some View {

        NavigationStack(path: $navigationPath) {
            VStack {
                ForEach(liveListViewModel.categories, id: \.id) { item in
                    Text(item.title)
                }
            }
            .navigationTitle(searchType.rawValue)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showModal.toggle()
                    }) {
                        Text("分类")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                }
            }
            .sheet(isPresented: $showModal) {
                ModalView(showModel: $showModal)
            }
        }
        
    }
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

struct ModalView: View {
    
    @Binding var showModel: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            Text("This is a modal view")
                .font(.title)
            SearchBar(text: $searchText)
            Spacer()
            Button(action: {
                showModel.toggle()
            }) {
                Text("Dismiss")
            }
        }
        .padding()
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(radius: 10)
    }
}

#Preview {
    LiveListView(searchType: .bilibili)
}
