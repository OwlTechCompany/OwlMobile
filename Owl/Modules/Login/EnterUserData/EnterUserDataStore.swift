//
//  EnterUserDataStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 16.04.2022.
//

import ComposableArchitecture

struct EnterUserData {

    // MARK: - State

    struct State: Equatable {
        @BindableState var firstName: String = ""
        @BindableState var lastName: String = ""
        var saveButtonEnabled: Bool = false
        var isLoading: Bool = false

        var alert: AlertState<Action>?
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case later
        case save

        case updateUserResult(Result<Bool, NSError>)
        case dismissAlert

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let firestoreUsersClient: FirestoreUsersClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {

        case .binding(\.$firstName):
            state.saveButtonEnabled = !state.firstName.isEmpty
            return .none

        case .later:
            return .none

        case .save:
            guard let authUser = environment.authClient.currentUser() else {
                return .none
            }
            state.isLoading = true
            let updateUser = UpdateUser(
                uid: authUser.uid,
                firstName: state.firstName,
                lastName: state.lastName
            )
            return environment.firestoreUsersClient.updateUser(updateUser)
                .catchToEffect(Action.updateUserResult)
                .eraseToEffect()

        case .updateUserResult(.success):
            state.isLoading = false
            return .none

        case let .updateUserResult(.failure(error)):
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

}
