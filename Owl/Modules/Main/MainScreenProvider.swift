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
        case chatList(ChatList.State)
        case chat(Chat.State)
        case newPrivateChat(NewPrivateChat.State)
        case profile(Profile.State)
        case editProfile(EditProfile.State)

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
        case chatList(ChatList.Action)
        case chat(Chat.Action)
        case newPrivateChat(NewPrivateChat.Action)
        case profile(Profile.Action)
        case editProfile(EditProfile.Action)
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
                        chatsClient: $0.chatsClient,
                        userClient: $0.userClient
                    )
                }
            ),
        Chat.reducer
            .pullback(
                state: /State.chat,
                action: /Action.chat,
                environment: {
                    Chat.Environment(
                        chatsClient: $0.chatsClient
                    )
                }
            ),
        NewPrivateChat.reducer
            .pullback(
                state: /State.newPrivateChat,
                action: /Action.newPrivateChat,
                environment: {
                    NewPrivateChat.Environment(
                        userClient: $0.userClient,
                        chatsClient: $0.chatsClient,
                        firestoreUsersClient: $0.firestoreUsersClient
                    )
                }
            ),
        Profile.reducer
            .pullback(
                state: /State.profile,
                action: /Action.profile,
                environment: {
                    Profile.Environment(
                        userClient: $0.userClient
                    )
                }
            ),
        EditProfile.reducer
            .pullback(
                state: /State.editProfile,
                action: /Action.editProfile,
                environment: {
                    EditProfile.Environment(
                        firestoreUsersClient: $0.firestoreUsersClient,
                        storageClient: $0.storageClient
                    )
                }
            )
    )

}
