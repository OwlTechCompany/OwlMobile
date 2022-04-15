//
//  MainScreenProvider.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import ComposableArchitecture
import TCACoordinators

extension Main {

    struct ScreenProvider {}
}

extension Main.ScreenProvider {

    // MARK: - Routes

    struct ChatListRoute: Routable {
        static var statePath = /State.chatList
    }

    struct ChatRoute: Routable {
        static var statePath = /State.chat
    }

    // MARK: - State handling

    enum State: Equatable, Identifiable {
        case chatList(ChatList.State)
        case chat(Chat.State)

        var id: String {
            switch self {
            case .chatList:
                return ChatListRoute.id

            case .chat:
                return ChatRoute.id
            }
        }
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case chatList(ChatList.Action)
        case chat(Chat.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Main.Environment>.combine(
        ChatList.reducer
            .pullback(
                state: /State.chatList,
                action: /Action.chatList,
                environment: { _ in ChatList.Environment() }
            ),
        Chat.reducer
            .pullback(
                state: /State.chat,
                action: /Action.chat,
                environment: { _ in Chat.Environment() }
            )
    )

}