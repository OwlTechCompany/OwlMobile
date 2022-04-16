//
//  ChatStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import ComposableArchitecture

struct Chat {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable { }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, _, _ in
        return .none
    }

}
