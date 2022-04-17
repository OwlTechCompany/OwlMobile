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

    struct NewPrivateChatRoute: Routable {
        static var statePath = /State.chat
    }

    // MARK: - State handling

    enum State: Equatable, Identifiable {
        case chatList(ChatList.State)
        case chat(Chat.State)
        case newPrivateChat(NewPrivateChat.State)

        var id: String {
            switch self {
            case .chatList:
                return ChatListRoute.id

            case .chat:
                return ChatRoute.id

            case .newPrivateChat:
                return NewPrivateChatRoute.id
            }
        }
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case chatList(ChatList.Action)
        case chat(Chat.Action)
        case newPrivateChat(NewPrivateChat.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Main.Environment>.combine(
        ChatList.reducer
            .pullback(
                state: /State.chatList,
                action: /Action.chatList,
                environment: {
                    ChatList.Environment(
                        authClient: $0.authClient,
                        chatsClient: $0.chatsClient
                    )
                }
            ),
        Chat.reducer
            .pullback(
                state: /State.chat,
                action: /Action.chat,
                environment: { _ in Chat.Environment() }
            ),
        NewPrivateChat.reducer
            .pullback(
                state: /State.newPrivateChat,
                action: /Action.newPrivateChat,
                environment: {
                    NewPrivateChat.Environment(
                        chatsClient: $0.chatsClient,
                        firestoreUsersClient: $0.firestoreUsersClient
                    )
                }
            )
    )

}
