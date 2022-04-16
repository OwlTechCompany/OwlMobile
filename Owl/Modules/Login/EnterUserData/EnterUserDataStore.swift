//
//  EnterUserDataStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import ComposableArchitecture

struct EnterUserData {

    // MARK: - State

    struct State: Equatable {
        @BindableState var firstName: String = ""
        @BindableState var lastName: String = ""
        var isLoading: Bool = false

        var alert: AlertState<Action>?
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case later
        case letsChat

        case dismissAlert

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .later:
            return .none

        case .letsChat:
            return .none

//        case let .authDataResult(.failure(error)),
//             let .verificationIDResult(.failure(error)),
//            let .setMeResult(.failure(error)):
//            state.isLoading = false
//            state.alert = .init(
//                title: TextState("Error"),
//                message: TextState("\(error.localizedDescription)"),
//                dismissButton: .default(TextState("Ok"))
//            )
//            return .none

        case .dismissAlert:
            state.alert = nil
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
