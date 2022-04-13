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
        @BindableState var isLoading: Bool
    }

    // MARK: - ViewAction

    enum Action: Equatable, BindableAction {

        case binding(BindingAction<State>)
        case delegate(DelegateAction)
        case sendPhoneNumber

        enum DelegateAction: Equatable {
            case verificationIDReceived(Result<String, NSError>)
        }
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .binding(\.$phoneNumber):
            return .none

        case .sendPhoneNumber:
            state.isLoading = true
            return environment.authClient
                .verifyPhoneNumber(state.phoneNumber)
                .mapError { $0 as NSError }
                .catchToEffect { Action.delegate(.verificationIDReceived($0)) }
                .eraseToEffect()

        case .delegate(.verificationIDReceived):
            state.isLoading = false
            return .none

        case .delegate:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
