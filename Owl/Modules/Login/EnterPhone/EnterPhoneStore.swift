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

        enum DelegateAction {
            case sendPhoneNumber
        }
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .binding(\.$phoneNumber):
            return .none

        case .delegate(.sendPhoneNumber):
            state.isLoading = true
            return .none

        case .delegate:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
