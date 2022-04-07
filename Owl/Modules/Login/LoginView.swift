//
//  LoginView.swift
//  Owl
//
//  Created by Anastasia Holovash on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

struct LoginState: Equatable {

}

// MARK: - Action

enum LoginAction: Equatable {
    case loginSuccess
    case sendPhoneNumber
}

// MARK: - Environment

struct LoginEnvironment {

}

// MARK: - Reducer

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { _, action, _ in
    switch action {
    case .loginSuccess:
        return .none
    case .sendPhoneNumber:
        return .none
    }
}

// MARK: - View

struct LoginView: View {

    var store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Hello, world!")
                    .foregroundColor(Colors.test.swiftUIColor)
                    .padding()
                Button(
                    action: {
                        viewStore.send(.loginSuccess)
                    },
                    label: {
                        Text("Some")
                    }
                )
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(store: Store(
            initialState: .init(),
            reducer: loginReducer,
            environment: LoginEnvironment()
        ))
    }
}
