//
//  ChatListStore.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import ComposableArchitecture
import Firebase
import SwiftUI

struct ChatList {

    // MARK: - State

    struct State: Equatable {
        var user: User
        var chats: IdentifiedArrayOf<ChatListCell.State>
        var chatsData: [ChatsListPrivateItem]

        static let initialState = State(
            chats: .init(),
            chatsData: []
        )
    }

    // MARK: - Action

    enum Action: Equatable {
        case openProfile
        case newPrivateChat
        case onAppear
        case updateUser(User)
        case getChatsResult(Result<[ChatsListPrivateItem], NSError>)

        case chats(id: String, action: ChatListCell.Action)
        case open(ChatsListPrivateItem)
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let chatsClient: FirestoreChatsClient
        let userClient: UserClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .newPrivateChat:
            return .none

        case .openProfile:
            return .none

        case .onAppear:
            return .merge(
                environment.chatsClient.getChats()
                    .catchToEffect(Action.getChatsResult),

                Effect.run { subscriber in
                    environment.userClient.firestoreUser
                        .compactMap { $0 }
                        .sink { subscriber.send(.updateUser($0)) }
                }
            )

        case let .updateUser(user):
            state.user = user
            return .none

        case let .chats(id, .open):
            guard let chat = state.chatsData.first(where: { $0.id == id }) else {
                return .none
            }
            return Effect(value: .open(chat))

        case let .getChatsResult(.success(items)):
            state.chats = .init(uniqueElements: items.map(ChatListCell.State.init(model:)))
            state.chatsData = items
            return .none

        case let .getChatsResult(.failure(error)):
            return .none

        case .open:
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
