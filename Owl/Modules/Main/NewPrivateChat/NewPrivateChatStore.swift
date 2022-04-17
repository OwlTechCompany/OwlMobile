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
        var isLoading: Bool = false
        var usersModels: [User] = []
        var users: IdentifiedArrayOf<NewPrivateChatCell.State>

        static let initialState = State(
            users: .init(
                uniqueElements: [
//                    NewPrivateChatCell.State(
//                        id: "1",
//                        image: Asset.Images.owlBlack.image,
//                        fullName: "Denys Danyliuk",
//                        phoneNumber: "+380992177560"
//                    ),
//                    NewPrivateChatCell.State(
//                        id: "2",
//                        image: Asset.Images.owlBlack.image,
//                        fullName: "Nastya holovash",
//                        phoneNumber: "+380931314850"
//                    ),
//                    NewPrivateChatCell.State(
//                        id: "3",
//                        image: Asset.Images.owlBlack.image,
//                        fullName: "Test Test",
//                        phoneNumber: "+380992177560"
//                    )
                ]
            )
        )
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case search
        case searchResult(Result<[User], NSError>)

        case users(id: String, action: NewPrivateChatCell.Action)

        case chatWithUserResult(Result<ChatWithUserResponse, NSError>)
        case createPrivateChat(String)
        case createPrivateChatResult(Result<ChatsListPrivateItem, NSError>)

        case openChat(ChatsListPrivateItem)

        case dismissAlert

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
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
            state.usersModels = users
            state.users = .init(uniqueElements: users.map(NewPrivateChatCell.State.init(model:)))
            return .none

        case let .searchResult(.failure(error)):
            state.isLoading = false
            state.alert = .init(
                title: TextState("Error"),
                message: TextState("\(error.localizedDescription)"),
                dismissButton: .default(TextState("Ok"))
            )
            return .none

        case let .users(withUserId, .open):
            return environment.chatsClient.chatWithUser(withUserId)
                .catchToEffect(Action.chatWithUserResult)

        case let .chatWithUserResult(.success(response)):
            switch response {
            case let .chatItem(item):
                return Effect(value: .openChat(item))

            case let .needToCreate(withUserID):
                return Effect(value: .createPrivateChat(withUserID))
            }

        case let .createPrivateChat(withUserId):
            state.isLoading = true
            let currentUser = Auth.auth().currentUser!
            let user = User(uid: currentUser.uid, phoneNumber: currentUser.phoneNumber!, firstName: "Wild", lastName: "Owl")
            let opponent = state.usersModels.first(where: { $0.uid == withUserId })!
            let privateChatRequest = PrivateChatRequest(
                createdBy: currentUser.uid,
                members: [
                    currentUser.uid,
                    withUserId
                ],
                user1: user,
                user2: opponent
            )

            return environment.chatsClient.createPrivateChat(privateChatRequest)
                .catchToEffect(Action.createPrivateChatResult)

        case let .createPrivateChatResult(.success(item)):
            state.isLoading = false
            return Effect(value: .openChat(item))

        case let .createPrivateChatResult(.failure(error)),
             let .chatWithUserResult(.failure(error)):
            state.isLoading = false
            return .none

        case .openChat:
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
                state: \State.users,
                action: /Action.users,
                environment: { _ in NewPrivateChatCell.Environment() }
            ),
        reducerCore
    )

}
