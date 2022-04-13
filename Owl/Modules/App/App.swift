//
//  App.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
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

        static let live = Environment(
            firebaseClient: .live,
            authClient: .live,
            userDefaultsClient: .live
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

        case .login:
            return .none

        default:
            return .none
        }
    }
}

// MARK: - View

struct AppView: View {

    let store: Store<App.State, App.Action>

    var body: some View {
        Group {
            IfLetStore(
                store.scope(state: \App.State.login, action: App.Action.login),
                then: LoginView.init
            )
            IfLetStore(
                store.scope(state: \App.State.main, action: App.Action.main),
                then: MainView.init
            )
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
            userDefaultsClient: userDefaultsClient
        )
    }

    var main: Main.Environment {
        Main.Environment()
    }

}
