//
//  AppView.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture
import SwiftUINavigation

// MARK: - State

struct AppState: Equatable {
    var appDelegate: AppDelegateState = AppDelegateState()
    var login: LoginFlowState?
    var main: MainState?

    mutating func setOnly(
        login: LoginFlowState? = nil,
        main: MainState? = nil
    ) {
        self.login = login
        self.main = main
    }
}

// MARK: - Action

enum AppAction: Equatable {
    case appDelegate(AppDelegateAction)
    case main(MainAction)
    case login(LoginFlowAction)
}

// MARK: - Environment

struct AppEnvironment {
    var firebaseClient: FirebaseClient
    var authClient: AuthClient
    var userDefaultsClient: UserDefaultsClient
}

extension AppEnvironment {
    static let live = AppEnvironment(
        firebaseClient: .live,
        authClient: .live,
        userDefaultsClient: .live
    )
}

extension AppEnvironment {
    var appDelegate: AppDelegateEnvironment {
        AppDelegateEnvironment(
            firebaseClient: firebaseClient,
            authClient: authClient
        )
    }

    var login: LoginFlowEnvironment {
        LoginFlowEnvironment(
            authClient: authClient,
            userDefaultsClient: userDefaultsClient
        )
    }

}

// MARK: - Reducer

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    appDelegateReducer
        .pullback(
            state: \AppState.appDelegate,
            action: /AppAction.appDelegate,
            environment: { $0.appDelegate }
        ),

    loginFlowReducer
        .optional()
        .pullback(
            state: \AppState.login,
            action: /AppAction.login,
            environment: { $0.login }
        ),

    mainReducer
        .optional()
        .pullback(
            state: \AppState.main,
            action: /AppAction.main,
            environment: { _ in MainEnvironment() }
        ),

    appReducerCore
).debug()

let appReducerCore = Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
    switch action {
    case .appDelegate(.didFinishLaunching):
        state.setOnly(login: .initialState)
        return .none

    case .login(.delegate(.loginSuccess)):
        state.setOnly(main: MainState())
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

struct AppView: View {

    let store: Store<AppState, AppAction>

    var body: some View {
        Group {
            IfLetStore(
                store.scope(state: \AppState.login, action: AppAction.login),
                then: LoginFlowView.init
            )
            IfLetStore(
                store.scope(state: \AppState.main, action: AppAction.main),
                then: { _ in Text("Main") }
            )
        }
    }
}
