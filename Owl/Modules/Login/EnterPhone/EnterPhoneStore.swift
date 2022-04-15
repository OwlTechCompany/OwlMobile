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
        @BindableState var isPhoneNumberValid: Bool = false
        var isLoading: Bool
    }

    // MARK: - ViewAction

    enum Action: Equatable, BindableAction {
        case verificationIDReceived(Result<String, NSError>)
        case sendPhoneNumber

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
                .mapError { $0 as NSError }
                .catchToEffect(Action.verificationIDReceived)
                .eraseToEffect()

        case let .verificationIDReceived(.success(verificationId)):
            state.isLoading = false
            environment.userDefaultsClient.setVerificationID(verificationId)
            return .none

        case let .verificationIDReceived(.failure(error)):
            print(error.localizedDescription)
            state.isLoading = false
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
