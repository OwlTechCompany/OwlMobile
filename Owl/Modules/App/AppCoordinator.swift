//
//  AppCoordinator.swift
//  Owl
//
//  Created by Denys Danyliuk on 11.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI
import SwiftUINavigation

//struct AppCoordinatorView: View {
//
//    let store: Store<AppState, AppAction>
//
//    var body: some View {
//        WithViewStore(store) { viewStore in
//            IfLetStore(
//                store.scope(
//                    state: \.login,
//                    action: AppAction.login
//                ),
//                then: { loginCoordinatorStore in
//                    LoginCoordinatorView(store: loginCoordinatorStore)
//                }
//            )
//        }
//
////        TCARouter(store) { screen in
////            SwitchStore(screen) {
////                CaseLet(
////                    state: /ScreenState.login,
////                    action: ScreenAction.login,
////                    then: LoginCoordinatorView.init
////                )
////            }
////        }
//    }
//}

//enum AppCoordinatorAction {
//
//    case login(LoginCoordinator.Action)
//}

//struct AppCoordinatorState: Equatable {
//
//    static let initialState = AppCoordinatorState(
//        login: .initialState
//    )
//
//    var login: LoginCoordinator.State?
//}

//struct AppCoordinatorEnvironment {}

//typealias AppCoordinatorReducer = Reducer<
//    AppState, AppAction, AppEnvironment
//>
//
//let appCoordinatorReducer: AppCoordinatorReducer = .combine(
//    loginCoordinatorReducer
//        .optional()
//        .pullback(
//            state: \AppState.login,
//            action: /AppAction.login,
//            environment: { _ in .init() }
//        )
//)
