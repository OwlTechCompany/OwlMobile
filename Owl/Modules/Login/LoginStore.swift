//
//  LoginStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 08.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

// MARK: - State

struct LoginState: Equatable, Hashable {

    @BindableState var phoneNumber: String
    @BindableState var verificationCode: String

    init() {
        phoneNumber = "+380931314850"
        verificationCode = ""
    }
}

// MARK: - Action

enum LoginAction: Equatable, BindableAction {
    case sendPhoneNumber
    case sendCode
    case verificationIDReceived(Result<String, NSError>)
    case authDataReceived(Result<AuthDataResult, NSError>)
    case loginSuccess

    case binding(BindingAction<LoginState>)
}

// MARK: - Environment

struct LoginEnvironment {
    let authClient: AuthClient
    let userDefaultsClient: UserDefaultsClient
}

// MARK: - Reducer

let loginReducer = Reducer<LoginState, LoginAction, LoginEnvironment> { state, action, environment in
    switch action {
    case .loginSuccess:
        return .none

    case .sendPhoneNumber:
        return environment.authClient
            .verifyPhoneNumber(state.phoneNumber)
            .mapError { $0 as NSError }
            .catchToEffect(LoginAction.verificationIDReceived)
            .eraseToEffect()

    case .sendCode:
        print(state.verificationCode)
        return .none

    case let .verificationIDReceived(.success(verificationId)):
        return .merge(
			.fireAndForget {
            	environment.userDefaultsClient.setVerificationID(verificationId)
        	}
		)

    case let .verificationIDReceived(.failure(error)):
        return .none

    case let .authDataReceived(.success(authData)):
        print(authData.user.phoneNumber)
        return .none

    case let .authDataReceived(.failure(error)):
        return .none

    case .binding(\.$phoneNumber):
        print("AAAAAAA")
        return .none

    case .binding:
        print(state.verificationCode)
        if state.verificationCode.count == 6 {
            let model = SignInModel(
                verificationID: environment.userDefaultsClient.getVerificationID(),
                verificationCode: state.verificationCode
            )
            return environment.authClient.signIn(model)
                .catchToEffect(LoginAction.authDataReceived)
                .eraseToEffect()

        } else {
            return .none
        }

    case let .binding(some):
        print(some)
        return .none
    }
}
.binding()
