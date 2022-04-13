//
//  MainStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

struct Main {

    // MARK: - State

    struct State: Equatable {

        static let initialState = State()
    }

    // MARK: - Action

    enum Action: Equatable {
        case logout
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .logout:
            return .none
        }
    }

}
