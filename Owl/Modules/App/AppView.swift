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
    var login: LoginState?
    var main: MainState?

    mutating func setOnly(
        login: LoginState? = nil,
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
    case login(LoginAction)
}

// MARK: - Environment

struct AppEnvironment {

}

// MARK: - Reducer

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    loginReducer
        .optional()
        .pullback(
            state: \AppState.login,
            action: /AppAction.login,
            environment: { _ in LoginEnvironment() }
        ),

    mainReducer
        .optional()
        .pullback(
            state: \AppState.main,
            action: /AppAction.main,
            environment: { _ in MainEnvironment() }
        ),

    appReducerCore
)

let appReducerCore = Reducer<AppState, AppAction, AppEnvironment> { state, action, _ in
    switch action {
    case .appDelegate(.didFinishLaunching):
        state.login = .init()
        return .none

    case .login(.loginSuccess):
        state.setOnly(main: MainState())
        return .none

    case .main(.logout):
        state.setOnly(login: LoginState())
        return .none

    default:
        return .none
    }
}

// MARK: - View

struct AppView: View {

    let store: Store<AppState, AppAction>
    @ObservedObject var viewStore: ViewStore<ViewState, AppAction>

    struct ViewState: Equatable {
        init(state: AppState) {

        }
    }

    init(store: Store<AppState, AppAction>) {
        self.store = store
        self.viewStore = ViewStore(self.store.scope(state: ViewState.init))
    }

    var body: some View {
        IfLetStore(
            self.store.scope(
                state: \.login,
                action: AppAction.login
            ),
            then: { mainStore in
                NavigationView {
                    LoginView(store: mainStore)
                        .navigationTitle("Login")
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        )
        .transition(.opacity)

        IfLetStore(
            self.store.scope(
                state: \.main,
                action: AppAction.main
            ),
            then: { mainStore in
                NavigationView {
                    MainView(store: mainStore)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        )
        .transition(.opacity)
    }
}
