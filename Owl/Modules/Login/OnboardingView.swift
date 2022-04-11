//
//  OnboardingView.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

struct OnboardingState: Equatable {
}

// MARK: - Action

enum OnboardingAction: Equatable {
    case startMessaging
}

// MARK: - Environment

struct OnboardingEnvironment {

}

// MARK: - Reducer

let onboardingReducer = Reducer<OnboardingState, OnboardingAction, OnboardingEnvironment> { state, action, environment in
    switch action {
    case .startMessaging:
        return .none
    }
}

// MARK: - View

struct OnboardingView: View {

    var store: Store<OnboardingState, OnboardingAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                VStack(spacing: 42) {
                    Rectangle()
                        .foregroundColor(.blue.opacity(0.2))
                        .frame(height: 270)
                        .cornerRadius(5)

                    Text("Connect easily with your family and friends over countries")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .padding()

                Spacer()

                Button {
                    viewStore.send(.startMessaging)
                } label: {
                    Text("Start Messaging")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(6)
                }
            }
            .padding(20)
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: Store(
            initialState: OnboardingState(),
            reducer: onboardingReducer,
            environment: OnboardingEnvironment()
        ))
    }
}
