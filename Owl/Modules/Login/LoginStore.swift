//
//  LoginStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import ComposableArchitecture

// MARK: - State

struct LoginState: Equatable {
    @BindableState var phoneNumber: String

    init() {
        phoneNumber = "+380931314850"
    }
}

// MARK: - Action

enum LoginAction: Equatable, BindableAction {
    case loginSuccess
    case sendPhoneNumber
    case verificationIDReceived(Result<String, NSError>)

    case binding(BindingAction<LoginState>)
}

// MARK: - Environment

struct LoginEnvironment {
    let authClient: AuthClient
}

// MARK: - Reducer

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {
    case .loginSuccess:
        return .none

    case .sendPhoneNumber:
        print(state.phoneNumber)
        return environment.authClient
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

    case .binding(\.$phoneNumber):
        print("Validating")
        print(state.phoneNumber)
        return .none

    case .binding:
        return .none
    }
}.binding()

