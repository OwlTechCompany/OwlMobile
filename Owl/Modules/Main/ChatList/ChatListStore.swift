//
//  ChatListStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import ComposableArchitecture

struct ChatList {

    // MARK: - State

    struct State: Equatable {
        var chats: IdentifiedArrayOf<ChatListCell.State>

        static let initialState = State(
            chats: .init()
        )
    }

    // MARK: - Action

    enum Action: Equatable {
        case logout

        case chats(id: String, action: ChatListCell.Action)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .logout:
            return .none

        case let .chats(id, .open):
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        ChatListCell.reducer
            .forEach(
                state: \.chats,
                action: /Action.chats,
                environment: { _ in ChatListCell.Environment() }
            ),
        reducerCore
    )

}
