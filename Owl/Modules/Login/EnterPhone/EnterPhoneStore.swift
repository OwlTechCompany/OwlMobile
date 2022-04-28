//
//  EnterPhoneStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

struct EnterPhone {

    // MARK: - ViewState

    struct State: Equatable {
        @BindableState var phoneNumber: String
        var isPhoneNumberValid: Bool = false
        var alert: AlertState<Action>?
        var isLoading: Bool
    }

    // MARK: - ViewAction

    enum Action: Equatable, BindableAction {
        case sendPhoneNumber
        case verificationIDResult(Result<String, NSError>)
        case dismissAlert

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let userDefaultsClient: UserDefaultsClient
        let phoneValidation: (String) -> Bool
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .binding(\.$phoneNumber):
            state.isPhoneNumberValid = environment.phoneValidation(state.phoneNumber)
            return .none

        case .sendPhoneNumber:
            state.isLoading = true
            return environment.authClient
                .verifyPhoneNumber(state.phoneNumber)
                .catchToEffect(Action.verificationIDResult)

        case let .verificationIDResult(.success(verificationId)):
            state.isLoading = false
            environment.userDefaultsClient.setVerificationID(verificationId)
            return .none

        case let .verificationIDResult(.failure(error)):
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
