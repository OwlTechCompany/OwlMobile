//
//  AppStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import ComposableArchitecture

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
        var firebaseClient: FirebaseClient
        var authClient: AuthClient
        var userDefaultsClient: UserDefaultsClient
        var validationClient: ValidationClient

        static let live = Environment(
            firebaseClient: .live,
            authClient: .live,
            userDefaultsClient: .live,
            validationClient: .live
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

    static var reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .appDelegate(.didFinishLaunching):
            state.setOnly(login: .initialState)
            return .none

        case .login(.delegate(.loginSuccess)):
            state.setOnly(main: .initialState)
            return .none

        case .main(.logout):
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
            validationClient: validationClient
        )
    }

    var main: Main.Environment {
        Main.Environment()
    }

}
