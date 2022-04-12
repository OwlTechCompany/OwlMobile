//
//  LoginFlow.swift
//  Owl
//
//  Created by Denys Danyliuk on 11.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI
import FirebaseAuth

// MARK: - State

struct LoginFlowState: Equatable, IdentifiedRouterState {

    var routes: IdentifiedArrayOf<Route<LoginScreenProviderState>>

    static let initialState = LoginFlowState(
        routes: [
            .root(.onboarding(OnboardingState()), embedInNavigationView: true)
        ]
    )
}

// MARK: - Action

enum LoginFlowAction: Equatable, IdentifiedRouterAction {

    case verificationIDReceived(Result<String, NSError>)
    case authDataReceived(Result<AuthDataResult, NSError>)
    case delegate(DelegateAction)

    case routeAction(LoginScreenProviderState.ID, action: LoginScreenProviderAction)
    case updateRoutes(IdentifiedArrayOf<Route<LoginScreenProviderState>>)

    enum DelegateAction: Equatable {
        case loginSuccess
    }
}

// MARK: - Environment

struct LoginFlowEnvironment {
    let authClient: AuthClient
    let userDefaultsClient: UserDefaultsClient
}

// MARK: - Reducer

typealias LoginFlowReducer = Reducer<LoginFlowState, LoginFlowAction, LoginFlowEnvironment>

private let loginFlowReducerCore = LoginFlowReducer { state, action, environment in
    switch action {
    case .routeAction(_, action: .onboarding(.startMessaging)):
        state.routes.push(.enterPhone(.init(phoneNumber: "+380931314850")))
        return .none

    case .routeAction(_, action: .enterPhone(.delegate(.sendPhoneNumber))):
        guard var enterPhoneState = state.subState(routePath: EnterPhoneRoute.self) else {
            return .none
        }
        return environment.authClient
            .verifyPhoneNumber(enterPhoneState.phoneNumber)
            .mapError { $0 as NSError }
            .catchToEffect(LoginFlowAction.verificationIDReceived)
            .eraseToEffect()

    case .routeAction(_, action: .enterCode(.delegate(.sendCode))),
         .routeAction(_, action: .enterCode(.delegate(.resendCode))):
        guard var enterCodeState = state.subState(routePath: EnterCodeRoute.self) else {
            return .none
        }
        let model = SignInModel(
            verificationID: environment.userDefaultsClient.getVerificationID(),
            verificationCode: enterCodeState.verificationCode
        )
        return environment.authClient.signIn(model)
            .catchToEffect(LoginFlowAction.authDataReceived)
            .eraseToEffect()

    case let .verificationIDReceived(.success(verificationId)):
        guard var enterPhoneState = state.subState(routePath: EnterPhoneRoute.self) else {
            return .none
        }
        environment.userDefaultsClient.setVerificationID(verificationId)
        state.routes.push(.enterCode(EnterCodeState(
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

let loginFlowReducer = LoginFlowReducer.combine(
    loginScreenProviderReducer
        .forEachIdentifiedRoute(environment: { $0 })
        .withRouteReducer(
            loginFlowReducerCore
        )
)

// MARK: - View

struct LoginFlowView: View {

    let store: Store<LoginFlowState, LoginFlowAction>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /LoginScreenProviderState.onboarding,
                    action: LoginScreenProviderAction.onboarding,
                    then: OnboardingView.init
                )
                CaseLet(
                    state: /LoginScreenProviderState.enterPhone,
                    action: LoginScreenProviderAction.enterPhone,
                    then: EnterPhoneView.init
                )
                CaseLet(
                    state: /LoginScreenProviderState.enterCode,
                    action: LoginScreenProviderAction.enterCode,
                    then: EnterCodeView.init
                )
            }
        }
    }
}
