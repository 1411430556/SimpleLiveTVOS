//
//  LiveListView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/4.
//

import SwiftUI
import LiveParse

struct LiveListView: View {
    
    @State private var navigationPath = [NavigationNode]()
    @State var searchType: LiveType
    @State private var searchText = ""
    @State private var showModal = false
    
    var body: some View {
//        Text("LiveListView:\(searchType)")
        NavigationStack(path: $navigationPath) {
            VStack {
                
            }
            .navigationTitle(searchType.rawValue)
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showModal.toggle()
                    }) {
                        Text("分类")
//                            .font(.title)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    SearchBar(text: $searchText)
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
    
    var body: some View {
        VStack {
            Text("This is a modal view")
                .font(.title)
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
