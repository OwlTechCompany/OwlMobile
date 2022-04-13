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

        case verificationIDReceived(Result<String, NSError>)
        case authDataReceived(Result<AuthDataResult, NSError>)
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
    }

    // MARK: - Reducer

    static private let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .routeAction(_, action: .onboarding(.startMessaging)):
            state.routes.push(.enterPhone(EnterPhone.State(phoneNumber: "+380931314850", isLoading: false)))
            return .none

        case .routeAction(_, action: .enterPhone(.delegate(.sendPhoneNumber))):
            return .none
            guard var enterPhoneState = state.subState(routePath: ScreenProvider.EnterPhoneRoute.self) else {
                return .none
            }
            return environment.authClient
                .verifyPhoneNumber(enterPhoneState.phoneNumber)
                .mapError { $0 as NSError }
                .catchToEffect(Action.verificationIDReceived)
                .eraseToEffect()

        case .routeAction(_, action: .enterCode(.delegate(.sendCode))),
             .routeAction(_, action: .enterCode(.delegate(.resendCode))):
            guard var enterCodeState = state.subState(routePath: ScreenProvider.EnterCodeRoute.self) else {
                return .none
            }
            let model = SignIn(
                verificationID: environment.userDefaultsClient.getVerificationID(),
                verificationCode: enterCodeState.verificationCode
            )
            return environment.authClient.signIn(model)
                .catchToEffect(Action.authDataReceived)
                .eraseToEffect()

        case let .verificationIDReceived(.success(verificationId)):
            guard var enterPhoneState = state.subState(routePath: ScreenProvider.EnterPhoneRoute.self) else {
                return .none
            }
            environment.userDefaultsClient.setVerificationID(verificationId)
            state.routes.push(.enterCode(EnterCode.State(
                verificationCode: "",
                phoneNumber: enterPhoneState.phoneNumber
            )))
            return .none

        case let .verificationIDReceived(.failure(error)):
            state.routes.goBackToRoot()
            return .none

        case let .authDataReceived(.success(authDataResult)):
            return Effect(value: .delegate(.loginSuccess))

        case let .authDataReceived(.failure(error)):
            return .none

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
            .withRouteReducer(
                reducerCore
            )
    )
}
