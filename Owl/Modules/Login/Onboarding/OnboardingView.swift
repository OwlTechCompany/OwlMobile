//
//  OnboardingView.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    let store: StoreOf<OnboardingFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                VStack(spacing: 50) {
                    Asset.Images.owlBlack.swiftUIImage
                        .frame(height: 270)
                        .cornerRadius(5)

                    VStack(spacing: 16) {
                        Text("Owl")
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .multilineTextAlignment(.center)

                        Text("Connect easily with your family and friends over countries")
                            .font(.system(size: 14, weight: .regular))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding()

                Spacer()

                Button(
                    action: { viewStore.send(.startMessaging) },
                    label: { Text("Start Messaging") }
                )
                .buttonStyle(BigButtonStyle())
            }
            .padding(20)
        }
        .background(
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: Store(
            initialState: OnboardingFeature.State(),
            reducer: OnboardingFeature()
        ))
    }
}
