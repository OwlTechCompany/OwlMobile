//
//  AdaptiveStack.swift
//  Owl
//
//  Created by Anastasia Holovash on 19.04.2022.
//

import SwiftUI

struct AdaptiveStack<Content: View>: View {
    @Binding var isHStack: Bool
    let horizontalAlignment: HorizontalAlignment
    let verticalAlignment: VerticalAlignment
    let spacing: CGFloat?
    let content: () -> Content

    init(
        isHStack: Binding<Bool>,
        horizontalAlignment: HorizontalAlignment = .trailing,
        verticalAlignment: VerticalAlignment = .bottom,
        spacing: CGFloat? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self._isHStack = isHStack
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        Group {
            if isHStack {
                HStack(
                    alignment: verticalAlignment,
                    spacing: spacing,
                    content: content
                )
            } else {
                VStack(
                    alignment: horizontalAlignment,
                    spacing: spacing,
                    content: content
                )
            }
        }
    }
}
