//
//  LiveDetailView.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/27.
//

import SwiftUI

struct LiveDetailView: View {
    
    @Environment(\.dismiss) var dismiss
//    let title: String
    
    var body: some View {
        VStack {
            customNavigationBar
            Text("Hello, World!")
            Spacer()
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
                
                Text("a")
                    .font(.headline)
                
                Spacer()
                
                // 为了平衡左侧按钮，可以添加一个占位视图
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
