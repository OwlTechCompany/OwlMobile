//
//  MainStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import TCACoordinators
import ComposableArchitecture

struct Main {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {

        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        static let initialState = State(
            routes: [
                .root(
                    .chatList(
                        ChatList.State(
                            chats: .init(arrayLiteral:
                                ChatListCell.State(
                                    documentID: "123",
                                    chatImage: Asset.Images.owlBlack.image,
                                    chatName: "Test chat",
                                    lastMessage: "Hello world",
                                    lastMessageSendTime: Date(),
                                    unreadMessagesNumber: 4
                                ),
                                 ChatListCell.State(
                                     documentID: "1237",
                                     chatImage: Asset.Images.owlBlack.image,
                                     chatName: "Test chat 3",
                                     lastMessage: "Hello world",
                                     lastMessageSendTime: Date(),
                                     unreadMessagesNumber: 4
                                 ),
                                 ChatListCell.State(
                                     documentID: "13",
                                     chatImage: Asset.Images.owlBlack.image,
                                     chatName: "Test chat 3",
                                     lastMessage: "Hello world Hello Hello Hello Hello HelloHello",
                                     lastMessageSendTime: Date(),
                                     unreadMessagesNumber: 209
                                 ),
                                 ChatListCell.State(
                                     documentID: "1235",
                                     chatImage: Asset.Images.owlBlack.image,
                                     chatName: "Test chat 4",
                                     lastMessage: "Hello world",
                                     lastMessageSendTime: Date(),
                                     unreadMessagesNumber: 4
                                 ),
                                  ChatListCell.State(
                                      documentID: "12376",
                                      chatImage: Asset.Images.owlBlack.image,
                                      chatName: "Test chat 5",
                                      lastMessage: "Hello world",
                                      lastMessageSendTime: Date(),
                                      unreadMessagesNumber: 4099
                                  ),
                                  ChatListCell.State(
                                      documentID: "137",
                                      chatImage: Asset.Images.owlBlack.image,
                                      chatName: "Test chat 6",
                                      lastMessage: "Hello world Hello Hello Hello Hello HelloHello",
                                      lastMessageSendTime: Date(),
                                      unreadMessagesNumber: 209
                                  )
                            )
                        )
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

    struct Environment { }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .routeAction(_, action: .chatList(.logout)):
            return Effect(value: .delegate(.logout))

        case let .routeAction(_, .chatList(.chats(id, action: .open))):
            state.routes.push(.chat(.init()))
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
