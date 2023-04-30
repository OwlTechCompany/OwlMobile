//
//  MainFlowCoordinator.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import SwiftUI

struct MainFlowCoordinator: Reducer {

    struct ListenersId: Hashable {}
    
    struct State: Equatable {
        var path: StackState<Path.State>
        var chatList: ChatListFeature.State

        init(user: User) {
            path = StackState()
            chatList = ChatListFeature.State(user: user, chats: [], chatsData: [])
        }
    }
    
    enum Action: Equatable {
        case chatList(ChatListFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
        case delegate(DelegateAction)
        
        enum DelegateAction: Equatable {
            case logout
        }
    }

    @Dependency(\.userClient) var userClient

    var body: some ReducerOf<Self> {
        Scope(state: \State.chatList, action: /Action.chatList) {
            ChatListFeature()
        }

        Reduce<State, Action> { state, action in
            switch action {
            case .chatList(.newPrivateChat):
                // TODO: What to do here?
//                state.routes.presentSheet(.newPrivateChat(NewPrivateChatFeature.State()), embedInNavigationView: true)
                return .none

            case .chatList(.openProfile):
                guard let firestoreUser = userClient.firestoreUser.value else {
                    return EffectPublisher(value: .delegate(.logout))
                }
                let profileState = ProfileFeature.State(user: firestoreUser)
                state.path.append(.profile(profileState))
                return .none

            case let .chatList(.open(chat)):
                state.path.append(.chat(.init(model: chat)))
                return .none

            case .path(.element(_, .chat(.navigation(.back)))):
                state.path.removeLast()
                return .none

            case let .path(.element(_, .newPrivateChat(.openChat(item)))):
                // TODO: What here?
                return .none
//                return EffectPublisher.routeWithDelaysIfUnsupported(state.routes) { provider in
//                    provider.dismiss()
//                    provider.push(.chat(.init(model: item)))
//                }

            case .path(.element(_, .profile(.close))):
                state.path.removeLast()
                return .none

            case .path(.element(_, .profile(.edit))):
                guard let firestoreUser = userClient.firestoreUser.value else {
                    return EffectPublisher(value: .delegate(.logout))
                }
                let editProfileState = EditProfileFeature.State(user: firestoreUser)
                state.path.append(.editProfile(editProfileState))
                return .none

            case .path(.element(_, .editProfile(.updateUserResult(.success)))):
                state.path.removeLast()
                return .none

            case .path(.element(_, .profile(.logout))):
                return EffectPublisher(value: .delegate(.logout))

            case .delegate:
                return .none

            case .path:
                return .none

            case .chatList:
                return .none
            }
        }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
    }
    
}
