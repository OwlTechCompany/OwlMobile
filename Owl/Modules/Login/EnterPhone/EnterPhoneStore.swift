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

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .binding(\.$phoneNumber):
            return .none

        case .delegate:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
