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
    var phoneNumber: String

    init() {
        phoneNumber = "+380931314850"
    }
}

// MARK: - Action

enum LoginAction: Equatable {
    case phoneNumberChanged(String)
    case loginSuccess
    case sendPhoneNumber
    case verificationIDReceived(Result<String, NSError>)
}

// MARK: - Environment

struct LoginEnvironment {
    let firebaseClient: FirebaseClient
}

// MARK: - Reducer

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {
    case let .phoneNumberChanged(newPhoneNumber):
        state.phoneNumber = newPhoneNumber
        return .none

    case .loginSuccess:
        return .none

    case .sendPhoneNumber:
        return environment.firebaseClient
            .verifyPhoneNumber(state.phoneNumber)
            .mapError { $0 as NSError }
            .catchToEffect(LoginAction.verificationIDReceived)
            .eraseToEffect()

    case let .verificationIDReceived(.success(verificationId)):
        print(verificationId)
        return .none

    case let .verificationIDReceived(.failure(error)):
        print(error.localizedDescription)
        return .none
    }
}

// MARK: - View

struct LoginView: View {

    var store: Store<LoginState, LoginAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                TextField(
                    "Phone number",
                    text: viewStore.binding(
                        get: \.phoneNumber,
                        send: LoginAction.phoneNumberChanged
                    )
                )
                Button(
                    action: {
                        viewStore.send(.sendPhoneNumber)
                    },
                    label: {
                        Text("Next")
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
            environment: LoginEnvironment(firebaseClient: .live)
        ))
    }
}
