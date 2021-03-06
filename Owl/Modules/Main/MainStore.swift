//
//  MainStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI

struct Main {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {

        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        static func initialState(user: User) -> State {
            State(routes: [
                .root(
                    .chatList(ChatList.State(user: user, chats: [], chatsData: [])),
                    embedInNavigationView: true
                )
            ])
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {

        case delegate(DelegateAction)

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)

        enum DelegateAction: Equatable {
            case logout
        }
    }

    // MARK: - Environment

    struct Environment {
        let userClient: UserClient
        let authClient: AuthClient
        let chatsClient: FirestoreChatsClient
        let firestoreUsersClient: FirestoreUsersClient
        let storageClient: StorageClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .routeAction(_, .chatList(.newPrivateChat)):
            state.routes.presentSheet(.newPrivateChat(NewPrivateChat.State()), embedInNavigationView: true)
            return .none

        case .routeAction(_, .chatList(.openProfile)):
            guard let firestoreUser = environment.userClient.firestoreUser.value else {
                return Effect(value: .delegate(.logout))
            }
            let profileState = Profile.State(user: firestoreUser)
            state.routes.push(.profile(profileState))
            return .none

        case let .routeAction(_, .chatList(.open(chat))):
            state.routes.push(.chat(.init(model: chat)))
            return .none

        case .routeAction(_, .chat(.navigation(.back))):
            state.routes.pop()
            return .none

        case let .routeAction(_, .newPrivateChat(.openChat(item))):
            return Effect.routeWithDelaysIfUnsupported(state.routes) { provider in
                provider.dismiss()
                provider.push(.chat(.init(model: item)))
            }

        case .routeAction(_, .profile(.close)):
            state.routes.pop()
            return .none

        case .routeAction(_, .profile(.edit)):
            guard let firestoreUser = environment.userClient.firestoreUser.value else {
                return Effect(value: .delegate(.logout))
            }
            let editProfileState = EditProfile.State(user: firestoreUser)
            state.routes.push(.editProfile(editProfileState))
            return .none

        case .routeAction(_, .editProfile(.updateUserResult(.success))):
            state.routes.pop()
            return .none

        case .routeAction(_, .profile(.logout)):
            return Effect(value: .delegate(.logout))

        case .delegate:
            return .none

        case .routeAction(_, action: let action):
            return .none

        case .updateRoutes:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Main.ScreenProvider.reducer
            .forEachIdentifiedRoute(environment: { $0 })
            .withRouteReducer(reducerCore)
    )

}
