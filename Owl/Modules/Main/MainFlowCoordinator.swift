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
            chatList = ChatListFeature.State(user: user)
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
    
    var core: some Reducer<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .chatList(.delegate(.openProfile)):
                guard let firestoreUser = userClient.firestoreUser.value else {
                    return .send(.delegate(.logout))
                }
                let profileState = ProfileFeature.State(user: firestoreUser)
                state.path.append(.profile(profileState))
                return .none
                
            case let .chatList(.delegate(.openChat(chatsListPrivateItem))):
                state.path.append(.chat(.init(model: chatsListPrivateItem)))
                return .none

            case .path(.element(_, .chat(.navigation(.back)))):
                state.path.removeLast()
                return .none
                
            case .path(.element(_, .profile(.close))):
                state.path.removeLast()
                return .none

            case .path(.element(_, .profile(.edit))):
                guard let firestoreUser = userClient.firestoreUser.value else {
                    return .send(.delegate(.logout))
                }
                let editProfileState = EditProfileFeature.State(user: firestoreUser)
                state.path.append(.editProfile(editProfileState))
                return .none

            case .path(.element(_, .editProfile(.updateUserResult(.success)))):
                state.path.removeLast()
                return .none

            case .path(.element(_, .profile(.logout))):
                return .send(.delegate(.logout))

            case .delegate:
                return .none

            case .path:
                return .none

            case .chatList:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.chatList, action: /Action.chatList) {
            ChatListFeature()
        }
        
        core.forEach(\.path, action: /Action.path) {
            Path()
        }
    }
    
}
