//
//  ViewModifiers.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import SwiftUI

struct ShadowModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
    }

}

struct TinyShadowModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .shadow(color: Colors.accentColor.swiftUIColor.opacity(0.1), radius: 1, x: 0, y: 1)
            .shadow(color: Colors.accentColor.swiftUIColor.opacity(0.3), radius: 3, x: 0, y: 2)
    }

}
