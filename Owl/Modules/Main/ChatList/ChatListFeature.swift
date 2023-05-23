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
        var chats: IdentifiedArrayOf<ChatListCellFeature.State> = []
        var chatsData: [ChatsListPrivateItem] = []
        @PresentationState var destination: Destination.State?
    }

    enum Action: Equatable {
        case profileButtonTapped
        case newPrivateChatButtonTapped
        case onAppear
        case updateUser(User)
        case getChatsResult(Result<[ChatsListPrivateItem], NSError>)

        case destination(PresentationAction<Destination.Action>)
        case chats(id: ChatListCellFeature.State.ID, action: ChatListCellFeature.Action)
        case delegate(Delegate)
        
        enum Delegate: Equatable {
            case openProfile
            case openChat(ChatsListPrivateItem)
        }
    }
    
    struct Destination: Reducer {
        enum State: Equatable {
            case newPrivateChat(NewPrivateChatFeature.State)
        }
        
        enum Action: Equatable {
            case newPrivateChat(NewPrivateChatFeature.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: /State.newPrivateChat, action: /Action.newPrivateChat) {
                NewPrivateChatFeature()
            }
        }
    }
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.firestoreChatsClient) var chatsClient
    @Dependency(\.userClient) var userClient

    var body: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
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
                .cancellable(id: MainFlowCoordinator.ListenersId())

            case let .updateUser(user):
                state.user = user
                return .none

            case let .chats(id, .open):
                guard let chat = state.chatsData.first(where: { $0.id == id }) else {
                    return .none
                }
                return .send(.delegate(.openChat(chat)))

            case let .getChatsResult(.success(items)):
                state.chats = .init(uniqueElements: items.map(ChatListCellFeature.State.init(model:)))
                state.chatsData = items
                return .none

            case let .getChatsResult(.failure(error)):
                return .none
                
            case .profileButtonTapped:
                return .send(.delegate(.openProfile))
                
            case .newPrivateChatButtonTapped:
                state.destination = .newPrivateChat(NewPrivateChatFeature.State())
                return .none
                
            case let .destination(.presented(.newPrivateChat(.openChat(chat)))):
                return .send(.delegate(.openChat(chat)))
                
            case let .destination(action):
                print("!!! \(action)")
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.chats, action: /Action.chats) {
            ChatListCellFeature()
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }

}
