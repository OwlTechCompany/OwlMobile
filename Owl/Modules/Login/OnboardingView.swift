//
//  OnboardingView.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - View

struct OnboardingView: View {

    // MARK: - Properties

    var store: Store<LoginState, LoginAction>

    var body: some View {
        VStack {
            Spacer()

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

            NavigationLink {
                EnterPhoneView(store: store)
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

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(store: Store(
            initialState: LoginState(),
            reducer: loginReducer,
            environment: AppEnvironment.live.login
        ))
    }
}
