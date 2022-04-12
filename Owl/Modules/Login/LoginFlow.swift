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
    case loginSuccess

    case routeAction(LoginScreenProviderState.ID, action: LoginScreenProviderAction)
    case updateRoutes(IdentifiedArrayOf<Route<LoginScreenProviderState>>)
}

// MARK: - Environment

struct LoginFlowEnvironment { }

// MARK: - Reducer

private let loginFlowReducerCore = Reducer<LoginFlowState, LoginFlowAction, LoginFlowEnvironment> { state, action, environment in
    switch action {
    case .routeAction(_, action: .enterPhone(.binding(\.$phoneNumber))):
        guard let enterPhoneState = state.subState(routePath: EnterPhoneRoute.self) else {
            return .none
        }
        print("!!!!!!!!!! \(enterPhoneState.phoneNumber)")
        return .none

    case .routeAction(_, action: .onboarding(.startMessaging)):
        print("Start messanging")
        state.routes.push(.enterPhone(.init(phoneNumber: "+380")))
        return .none

    case .routeAction(_, action: .enterPhone(.sendPhoneNumber)):
        guard var enterPhoneState = state.subState(routePath: EnterPhoneRoute.self) else {
            return .none
        }
        //        if let screenProviderState = state.routes[id: .enterPhone]?.screen {
        //            let casePath: CasePath<ScreenProviderState, EnterPhoneState> = RoutePath.enterPhone.path()
        //            let oldState = casePath.extract(from: screenProviderState)!
        //            var newState = oldState
        //            newState.phoneNumber = "++++"
        //            enterPhoneState = newState
        //            state.routes[id: .enterPhone]?.screen = casePath.embed(newState)
        //        }
        //        state.
        //        enterPhoneState.phoneNumber
        state.routes.push(.enterCode(EnterCodeState(verificationCode: "", phoneNumber: enterPhoneState.phoneNumber)))
        return .none

    default:
        return .none
    }
}

let loginFlowReducer = Reducer<LoginFlowState, LoginFlowAction, LoginFlowEnvironment>.combine(
    loginScreenProviderReducer
        .forEachIdentifiedRoute(environment: { _ in .init() })
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

