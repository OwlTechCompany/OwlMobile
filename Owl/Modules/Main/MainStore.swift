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

        static let initialState = State(
            routes: [
                .root(
                    .chatList(
                        ChatList.State.initialState
                    ),
                    embedInNavigationView: true
                )
            ]
        )
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
        let authClient: AuthClient
        let chatsClient: FirestoreChatsClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .routeAction(_, action: .chatList(.logout)):
            return Effect(value: .delegate(.logout))

        case let .routeAction(_, .chatList(.chats(id, action: .open))):
            state.routes.push(.chat(.init(
                navigation: .init(
                    model: MockedDataClient.chatsListPrivateItem
                ),
                messages: .init(
                    uniqueElements: MockedDataClient.chatMessages.map {
                        ChatMessage.State(
                            message: $0,
                            companion: MockedDataClient.chatsListPrivateItem.companion
                        )
                    }
                )
            )))
            return .none

        case .routeAction(_, .chat(.navigation(.back))):
            state.routes.pop()
            return .none

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
