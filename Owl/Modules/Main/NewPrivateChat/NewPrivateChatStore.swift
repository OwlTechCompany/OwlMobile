//
//  NewPrivateChatStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

struct NewPrivateChat {

    // MARK: - State

    struct State: Equatable {
        @BindableState var searchText: String = ""
        var alert: AlertState<Action>?
        var emptyViewState: EmptyViewState = .onAppear
        var isLoading: Bool = false
        var users: [User] = []
        var cells: IdentifiedArrayOf<NewPrivateChatCell.State> = []

        enum EmptyViewState {
            case onAppear
            case notFound
            case hidden
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case search
        case searchResult(Result<[User], NSError>)

        case cells(id: String, action: NewPrivateChatCell.Action)

        case chatWithUserResult(Result<ChatWithUserResponse, NSError>)
        case createPrivateChat(opponentId: String)
        case createPrivateChatResult(Result<ChatsListPrivateItem, NSError>)

        case openChat(ChatsListPrivateItem)
        case dismissAlert
        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let userClient: UserClient
        let chatsClient: FirestoreChatsClient
        let firestoreUsersClient: FirestoreUsersClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .search:
            state.isLoading = true
            let userQuery = UserQuery(phoneNumber: state.searchText)
            return environment.firestoreUsersClient.users(userQuery)
                .catchToEffect(Action.searchResult)

        case let .searchResult(.success(users)):
            state.isLoading = false
            state.users = users
            state.cells = .init(uniqueElements: users.map(NewPrivateChatCell.State.init(model:)))
            if users.isEmpty {
                state.emptyViewState = .notFound
            } else {
                state.emptyViewState = .hidden
            }
            return .none

        case let .cells(userId, .open):
            state.isLoading = true
            return environment.chatsClient.chatWithUser(userId)
                .catchToEffect(Action.chatWithUserResult)

        case let .chatWithUserResult(.success(response)):
            switch response {
            case let .chatItem(item):
                return Effect(value: .openChat(item))

            case let .needToCreate(userID):
                return Effect(value: .createPrivateChat(opponentId: userID))
            }

        case let .createPrivateChat(userId):
            guard let firestoreUser = environment.userClient.firestoreUser.value else {
                return .none
            }
            state.isLoading = true
            let opponent = state.users.first(where: { $0.uid == userId })!
            let privateChatCreate = PrivateChatCreate(
                createdBy: firestoreUser.uid,
                members: [
                    firestoreUser.uid,
                    userId
                ],
                user1: firestoreUser,
                user2: opponent
            )
            return environment.chatsClient.createPrivateChat(privateChatCreate)
                .catchToEffect(Action.createPrivateChatResult)

        case let .createPrivateChatResult(.success(item)):
            return Effect(value: .openChat(item))

        case let .searchResult(.failure(error)),
             let .chatWithUserResult(.failure(error)),
             let .createPrivateChatResult(.failure(error)):
            state.isLoading = false
            state.alert = .init(
                title: TextState("Error"),
                message: TextState("\(error.localizedDescription)"),
                dismissButton: .default(TextState("Ok"))
            )
            return .none

        case .openChat:
            state.isLoading = false
            return .none

        case .dismissAlert:
            state.alert = nil
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

    static let reducer = Reducer<State, Action, Environment>.combine(
        NewPrivateChatCell.reducer
            .forEach(
                state: \State.cells,
                action: /Action.cells,
                environment: { _ in NewPrivateChatCell.Environment() }
            ),
        reducerCore
    )

}
