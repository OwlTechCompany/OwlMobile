//
//  NewPrivateChatFeature.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

struct NewPrivateChatFeature: Reducer {
    
    struct State: Equatable {
        @BindingState var searchText: String = ""
        var alert: AlertState<Action>?
        var emptyViewState: EmptyViewState = .onAppear
        var isLoading: Bool = false
        var users: [User] = []
        var cells: IdentifiedArrayOf<NewPrivateChatCellFeature.State> = []

        enum EmptyViewState {
            case onAppear
            case notFound
            case hidden
        }
    }

    enum Action: Equatable, BindableAction {
        case search
        case searchResult(Result<[User], NSError>)

        case cells(id: String, action: NewPrivateChatCellFeature.Action)

        case chatWithUserResult(Result<ChatWithUserResponse, NSError>)
        case createPrivateChat(opponentId: String)
        case createPrivateChatResult(Result<ChatsListPrivateItem, NSError>)

        case openChat(ChatsListPrivateItem)
        case dismissAlert
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.userClient) var userClient
    @Dependency(\.firestoreChatsClient) var chatsClient
    @Dependency(\.firestoreUsersClient) var firestoreUsersClient
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            case .search:
                state.isLoading = true
                let userQuery = UserQuery(phoneNumber: state.searchText)
                return firestoreUsersClient.users(userQuery)
                    .catchToEffect(Action.searchResult)

            case let .searchResult(.success(users)):
                state.isLoading = false
                state.users = users
                state.cells = .init(uniqueElements: users.map(NewPrivateChatCellFeature.State.init(model:)))
                if users.isEmpty {
                    state.emptyViewState = .notFound
                } else {
                    state.emptyViewState = .hidden
                }
                return .none

            case let .cells(userId, .open):
                state.isLoading = true
                return chatsClient.chatWithUser(userId)
                    .catchToEffect(Action.chatWithUserResult)

            case let .chatWithUserResult(.success(response)):
                switch response {
                case let .chatItem(item):
                    return EffectPublisher(value: .openChat(item))

                case let .needToCreate(userID):
                    return EffectPublisher(value: .createPrivateChat(opponentId: userID))
                }

            case let .createPrivateChat(userId):
                guard let firestoreUser = userClient.firestoreUser.value else {
                    return .none
                }
                state.isLoading = true
                let opponent = state.users.first(where: { $0.uid == userId })!
                let privateChatCreate = PrivateChatCreate(
                    createdBy: firestoreUser.uid,
                    membersIDs: [
                        firestoreUser.uid,
                        userId
                    ],
                    members: [
                        firestoreUser,
                        opponent
                    ]
                )
                return chatsClient.createPrivateChat(privateChatCreate)
                    .catchToEffect(Action.createPrivateChatResult)

            case let .createPrivateChatResult(.success(item)):
                return EffectPublisher(value: .openChat(item))

            case let .searchResult(.failure(error)),
                 let .chatWithUserResult(.failure(error)),
                 let .createPrivateChatResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState(
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
        .forEach(\State.cells, action: /Action.cells) {
            NewPrivateChatCellFeature()
        }
    }
    
}
