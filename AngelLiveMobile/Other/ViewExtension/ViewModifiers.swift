//
//  ViewModifiers.swift
//  AngelLiveMobile
//
//  Created by pc on 2024/9/27.
//

import SwiftUI

extension View {
    func transitionSource(id: String, namespace: Namespace.ID) -> some View {
        self.modifier(TransitionSourceModifier(id: id, namespace: namespace))
    }
}

private struct TransitionSourceModifier: ViewModifier {
    var id: String
    var namespace: Namespace.ID

    func body(content: Content) -> some View {
        content
            #if os(iOS)
            .matchedTransitionSource(id: id, in: namespace) { src in
                src
                    .clipShape(.rect(cornerRadius: 10.0))
                    .shadow(radius: 12.0)
                    .background(.black)
            }
            #endif
    }
}
