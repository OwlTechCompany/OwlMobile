//
//  LoginStore.swift
//  Owl
//
//  Created by Denys Danyliuk on 11.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI
import FirebaseAuth

struct Login {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {

        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        static let initialState = State(
            routes: [
                .root(.onboarding(Onboarding.State()), embedInNavigationView: true)
            ]
        )
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {

        case delegate(DelegateAction)

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)

        enum DelegateAction: Equatable {
            case loginSuccess
        }
    }

    // MARK: - Environment

    struct Environment {
        let authClient: AuthClient
        let userDefaultsClient: UserDefaultsClient
        let validationClient: ValidationClient
        let firestoreUsersClient: FirestoreUsersClient
    }

    // MARK: - Reducer

    static private let reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .routeAction(_, action: .onboarding(.startMessaging)):
            state.routes.push(.enterPhone(EnterPhone.State(phoneNumber: "+380", isLoading: false)))
            return .none

        case .routeAction(_, action: .enterPhone(.verificationIDResult(.success))):
            guard var enterPhoneState = state.subState(routePath: ScreenProvider.EnterPhoneRoute.self) else {
                return .none
            }
            state.routes.push(.enterCode(EnterCode.State(
                verificationCode: "",
                phoneNumber: enterPhoneState.phoneNumber
            )))
            return .none

        case .routeAction(_, action: .enterCode(.setMeResult(.success))):
            state.routes.push(.enterUserData(.init()))
            return .none

        case .routeAction(_, action: .enterUserData(.later)):
            return Effect(value: .delegate(.loginSuccess))

        case .routeAction:
            return .none

        case .updateRoutes:
            return .none

        case .delegate:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Login.ScreenProvider.reducer
            .forEachIdentifiedRoute(environment: { $0 })
            .withRouteReducer(reducerCore)
    )
}
