//
//  ChatListFeature.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import ComposableArchitecture
import Firebase
import SwiftUI

struct ChatListFeature: Reducer {

    struct State: Equatable {
        var user: User
        var chats: IdentifiedArrayOf<ChatListCellFeature.State>
        var chatsData: [ChatsListPrivateItem]
    }

    enum Action: Equatable {
        case openProfile
        case newPrivateChat
        case onAppear
        case updateUser(User)
        case getChatsResult(Result<[ChatsListPrivateItem], NSError>)

        case chats(id: ChatListCellFeature.State.ID, action: ChatListCellFeature.Action)
        case open(ChatsListPrivateItem)
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.firestoreChatsClient) var chatsClient
    @Dependency(\.userClient) var userClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .newPrivateChat:
                return .none

            case .openProfile:
                return .none

            case .onAppear:
                // This is workaround because .onDisappear can't
                // call viewState in ChatView
                chatsClient.openedChatId.send(nil)
                return .merge(
                    chatsClient.getChats()
                        .catchToEffect(Action.getChatsResult),

                    EffectPublisher.run { subscriber in
                        userClient.firestoreUser
                            .compactMap { $0 }
                            .sink { subscriber.send(.updateUser($0)) }
                    }
                )
                .cancellable(id: Main.ListenersId())

            case let .updateUser(user):
                state.user = user
                return .none

            case let .chats(id, .open):
                guard let chat = state.chatsData.first(where: { $0.id == id }) else {
                    return .none
                }
                return EffectPublisher(value: .open(chat))

            case let .getChatsResult(.success(items)):
                state.chats = .init(uniqueElements: items.map(ChatListCellFeature.State.init(model:)))
                state.chatsData = items
                return .none

            case let .getChatsResult(.failure(error)):
                return .none

            case .open:
                return .none
            }
        }
        .forEach(\.chats, action: /Action.chats) {
            ChatListCellFeature()
        }
    }

}
