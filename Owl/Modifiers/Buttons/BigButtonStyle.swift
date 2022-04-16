//
//  BigButtonStyle.swift
//  Owl
//
//  Created by Denys Danyliuk on 15.04.2022.
//

import SwiftUI

struct BigButtonStyle: ButtonStyle {

    func makeBody(configuration: Self.Configuration) -> some View {
        BigButtonStyleView(configuration: configuration)
    }

}

private extension BigButtonStyle {

    struct BigButtonStyleView: View {

        @Environment(\.isEnabled) var isEnabled

        let configuration: BigButtonStyle.Configuration

        var body: some View {
            return configuration.label
                .opacity(configuration.isPressed ? 0.8 : 1.0)
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundColor(.white)
                .background(
                    Asset.Colors.accentColor.swiftUIColor
                        .opacity(isEnabled ? 1.0 : 0.5)
                )
                .cornerRadius(6)
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeOut(duration: 0.33), value: configuration.isPressed)
        }
    }

}
