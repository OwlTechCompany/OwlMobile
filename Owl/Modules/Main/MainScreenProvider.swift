//
//  MainScreenProvider.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import ComposableArchitecture
import TCACoordinators

extension Main {

    struct ScreenProvider { }
    
}

extension Main.ScreenProvider: ReducerProtocol {

    // MARK: - Routes

    struct ChatListRoute: Routable {
        static var statePath = /State.chatList
    }

    struct ChatRoute: Routable {
        static var statePath = /State.chat
    }

    struct NewPrivateChatRoute: Routable {
        static var statePath = /State.newPrivateChat
    }

    struct ProfileRoute: Routable {
        static var statePath = /State.profile
    }

    struct EditProfileRoute: Routable {
        static var statePath = /State.editProfile
    }

    // MARK: - State handling

    enum State: Equatable, Identifiable {
        case chatList(ChatListFeature.State)
        case chat(Chat.State)
        case newPrivateChat(NewPrivateChatFeature.State)
        case profile(ProfileFeature.State)
        case editProfile(EditProfileFeature.State)

        var id: String {
            switch self {
            case .chatList:
                return ChatListRoute.id

            case .chat:
                return ChatRoute.id

            case .newPrivateChat:
                return NewPrivateChatRoute.id

            case .profile:
                return ProfileRoute.id

            case .editProfile:
                return EditProfileRoute.id
            }
        }
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case chatList(ChatListFeature.Action)
        case chat(Chat.Action)
        case newPrivateChat(NewPrivateChatFeature.Action)
        case profile(ProfileFeature.Action)
        case editProfile(EditProfileFeature.Action)
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: /State.chatList, action: /Action.chatList) {
            ChatListFeature()
        }

        Scope(state: /State.newPrivateChat, action: /Action.newPrivateChat) {
            NewPrivateChatFeature()
        }
        
        Scope(state: /State.profile, action: /Action.profile) {
            ProfileFeature()
        }
        
        Scope(state: /State.editProfile, action: /Action.editProfile) {
            EditProfileFeature()
        }
    }

}
