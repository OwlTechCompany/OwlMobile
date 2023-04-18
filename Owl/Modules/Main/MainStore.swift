//
//  MainStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI

struct Main: ReducerProtocol {

    struct ListenersId: Hashable {}

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {

        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        static func initialState(user: User) -> State {
            State(routes: [
                .root(
                    .chatList(ChatListFeature.State(user: user, chats: [], chatsData: [])),
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

    @Dependency(\.userClient) var userClient

    var bodyCore: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .routeAction(_, .chatList(.newPrivateChat)):
                state.routes.presentSheet(.newPrivateChat(NewPrivateChatFeature.State()), embedInNavigationView: true)
                return .none

            case .routeAction(_, .chatList(.openProfile)):
                guard let firestoreUser = userClient.firestoreUser.value else {
                    return EffectPublisher(value: .delegate(.logout))
                }
                let profileState = ProfileFeature.State(user: firestoreUser)
                state.routes.push(.profile(profileState))
                return .none

            case let .routeAction(_, .chatList(.open(chat))):
                state.routes.push(.chat(.init(model: chat)))
                return .none

            case .routeAction(_, .chat(.navigation(.back))):
                state.routes.pop()
                return .none

            case let .routeAction(_, .newPrivateChat(.openChat(item))):
                return EffectPublisher.routeWithDelaysIfUnsupported(state.routes) { provider in
                    provider.dismiss()
                    provider.push(.chat(.init(model: item)))
                }

            case .routeAction(_, .profile(.close)):
                state.routes.pop()
                return .none

            case .routeAction(_, .profile(.edit)):
                guard let firestoreUser = userClient.firestoreUser.value else {
                    return EffectPublisher(value: .delegate(.logout))
                }
                let editProfileState = EditProfileFeature.State(user: firestoreUser)
                state.routes.push(.editProfile(editProfileState))
                return .none

            case .routeAction(_, .editProfile(.updateUserResult(.success))):
                state.routes.pop()
                return .none

            case .routeAction(_, .profile(.logout)):
                return EffectPublisher(value: .delegate(.logout))

            case .delegate:
                return .none

            case .routeAction:
                return .none

            case .updateRoutes:
                return .none
            }
        }
    }

    var body: some ReducerProtocol<State, Action> {
        bodyCore.forEachRoute {
            Main.ScreenProvider()
        }
    }
}
