//
//  NewPrivateChatStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 17.04.2022.
//


import ComposableArchitecture

struct NewPrivateChat {

    // MARK: - State

    struct State: Equatable {
        @BindableState var searchText: String = ""
        var alert: AlertState<Action>?
        var isLoading: Bool = false
        var users: IdentifiedArrayOf<NewPrivateChatCell.State>

        static let initialState = State(
            users: .init(
                uniqueElements: [
                    NewPrivateChatCell.State(
                        id: "1",
                        image: Asset.Images.owlBlack.image,
                        fullName: "Denys Danyliuk",
                        phoneNumber: "+380992177560"
                    ),
                    NewPrivateChatCell.State(
                        id: "2",
                        image: Asset.Images.owlBlack.image,
                        fullName: "Nastya holovash",
                        phoneNumber: "+380931314850"
                    ),
                    NewPrivateChatCell.State(
                        id: "3",
                        image: Asset.Images.owlBlack.image,
                        fullName: "Test Test",
                        phoneNumber: "+380992177560"
                    )
                ]
            )
        )
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case search
        case searchResult(Result<[User], NSError>)

        case dismissAlert

        case binding(BindingAction<State>)
        case users(id: String, action: NewPrivateChatCell.Action)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case let .users(id, .open):
            return .none

        case .search:
            state.isLoading = true
            return .none

        case let .searchResult(.success(users)):
            state.isLoading = false
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
