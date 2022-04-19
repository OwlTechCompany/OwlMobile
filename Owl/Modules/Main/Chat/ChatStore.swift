//
//  ChatStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import ComposableArchitecture

struct Chat {

    // MARK: - State

    struct State: Equatable {
        var navigation: ChatNavigation.State
        var messages: IdentifiedArrayOf<ChatMessage.State>
    }

    // MARK: - Action

    enum Action: Equatable {
        case navigation(ChatNavigation.Action)
        case messages(id: String, action: ChatMessage.Action)

        case getMessagesResult(Result<[Message], NSError>)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .navigation:
            return .none
            
        case .getMessagesResult(_):
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        ChatNavigation.reducer
            .pullback(
                state: \State.navigation,
                action: /Action.navigation,
                environment: { _ in ChatNavigation.Environment() }
            ),
        reducerCore
    )

}
