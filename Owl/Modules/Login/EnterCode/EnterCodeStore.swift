//
//  EnterCodeStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

struct EnterCode {

    // MARK: - State

    struct State: Equatable {
        @BindableState var verificationCode: String
        var alert: AlertState<Action>?
        var phoneNumber: String
        var isLoading: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case sendCode
        case resendCode

        case verificationIDReceived(Result<String, NSError>)
        case authDataReceived(Result<AuthDataResult, NSError>)

        case dismissAlert

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let userDefaultsClient: UserDefaultsClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .binding(\.$verificationCode):
            if state.verificationCode.count == EnterCodeView.Constants.codeSize {
                return Effect(value: .sendCode)
            } else {
                return .none
            }

        case .sendCode:
            state.isLoading = true
            let verificationID = environment.userDefaultsClient.getVerificationID()
            let model = SignIn(
                verificationID: verificationID,
                verificationCode: state.verificationCode
            )
            return environment.authClient.signIn(model)
                .catchToEffect(Action.authDataReceived)
                .eraseToEffect()

        case let .authDataReceived(.success(result)):
            state.isLoading = false
            return .none

        case let .verificationIDReceived(.success(verificationId)):
            state.isLoading = false
            environment.userDefaultsClient.setVerificationID(verificationId)
            return .none

        case .resendCode:
            state.isLoading = true
            return environment.authClient
                .verifyPhoneNumber(state.phoneNumber)
                .mapError { $0 as NSError }
                .catchToEffect(Action.verificationIDReceived)
                .eraseToEffect()

        case let .authDataReceived(.failure(error)),
             let .verificationIDReceived(.failure(error)):
            state.isLoading = false
            state.alert = .init(
                title: TextState("Error"),
                message: TextState("\(error.localizedDescription)"),
                dismissButton: .default(TextState("Ok"))
            )
            return .none


        case .dismissAlert:
            state.alert = nil
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
