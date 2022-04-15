//
//  AppStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture
import FirebaseAuth

struct App {

    // MARK: - State

    struct State: Equatable {
        var appDelegate: AppDelegate.State = AppDelegate.State()
        var login: Login.State?
        var main: Main.State?

        mutating func setOnly(
            login: Login.State? = nil,
            main: Main.State? = nil
        ) {
            self.login = login
            self.main = main
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case appDelegate(AppDelegate.Action)
        case login(Login.Action)
        case main(Main.Action)
    }

    // MARK: - Environment

    struct Environment {
        let firebaseClient: FirebaseClient
        let authClient: AuthClient
        let userDefaultsClient: UserDefaultsClient
        let validationClient: ValidationClient
        let firestoreUsersClient: FirestoreUsersClient

        static let live = Environment(
            firebaseClient: .live,
            authClient: .live,
            userDefaultsClient: .live,
            validationClient: .live,
            firestoreUsersClient: .live
        )
    }

    // MARK: - Reducer

    static var reducer = Reducer<State, Action, Environment>.combine(
        AppDelegate.reducer
            .pullback(
                state: \State.appDelegate,
                action: /Action.appDelegate,
                environment: { $0.appDelegate }
            ),

        Login.reducer
            .optional()
            .pullback(
                state: \State.login,
                action: /Action.login,
                environment: { $0.login }
            ),

        Main.reducer
            .optional()
            .pullback(
                state: \State.main,
                action: /Action.main,
                environment: { $0.main }
            ),

        reducerCore
    ).debug()

    static var reducerCore = Reducer<State, Action, Environment> { state, action, env in
        switch action {
        case .appDelegate(.didFinishLaunching):
            if let currentUser = Auth.auth().currentUser {
                print(currentUser)
//                FirebaseAuth.User
                state.setOnly(main: .initialState)
            } else {
                state.setOnly(login: .initialState)
            }
            return .none

        case .login(.delegate(.loginSuccess)):
            state.setOnly(main: .initialState)
            return .none

        case .main(.logout):
            try? Auth.auth().signOut()
            state.setOnly(login: .initialState)
            return .none

        case .appDelegate:
            return .none

        case .login:
            return .none

        case .main:
            return .none
        }
    }
}

// MARK: App.Environment + Extensions

extension App.Environment {

    var appDelegate: AppDelegate.Environment {
        AppDelegate.Environment(
            firebaseClient: firebaseClient,
            authClient: authClient
        )
    }

    var login: Login.Environment {
        Login.Environment(
            authClient: authClient,
            userDefaultsClient: userDefaultsClient,
            validationClient: validationClient,
            firestoreUsersClient: firestoreUsersClient
        )
    }

    var main: Main.Environment {
        Main.Environment()
    }

}
