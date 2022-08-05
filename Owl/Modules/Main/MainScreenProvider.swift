//
//  MainScreenProvider.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import ComposableArchitecture
import TCACoordinators

extension Main {

    struct ScreenProvider {

        // TODO: Remove after migration Main.ScreenProvider to ReducerProtocol
        @Dependency(\.authClient) var authClient
        @Dependency(\.userClient) var userClient
        @Dependency(\.firestoreChatsClient) var firestoreChatsClient
        @Dependency(\.firestoreUsersClient) var firestoreUsersClient
        @Dependency(\.storageClient) var storageClient

    }
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

    var body: some ReducerProtocolOf<Self> {
        ScopeCase(
            state: /State.chatList,
            action: /Action.chatList
        ) {
            Reduce(
                ChatList.reducer,
                environment: ChatList.Environment(
                    authClient: authClient,
                    chatsClient: firestoreChatsClient,
                    userClient: userClient
                )
            )
        }

        ScopeCase(
            state: /State.newPrivateChat,
            action: /Action.newPrivateChat
        ) {
            Reduce(
                NewPrivateChat.reducer,
                environment: NewPrivateChat.Environment(
                    userClient: userClient,
                    chatsClient: firestoreChatsClient,
                    firestoreUsersClient: firestoreUsersClient
                )
            )
        }

        ScopeCase(
            state: /State.profile,
            action: /Action.profile
        ) {
            Reduce(
                Profile.reducer,
                environment: Profile.Environment(
                    userClient: userClient
                )
            )
        }

        ScopeCase(
            state: /State.editProfile,
            action: /Action.editProfile
        ) {
            Reduce(
                EditProfile.reducer,
                environment: EditProfile.Environment(
                    firestoreUsersClient: firestoreUsersClient,
                    storageClient: storageClient
                )
            )
        }
    }

}
