//
//  LoginCoordinator.swift
//  Owl
//
//  Created by Denys Danyliuk on 11.04.2022.
//

import TCACoordinators
import ComposableArchitecture
import SwiftUI
import FirebaseAuth

// MARK: - Screen

enum RoutePath: Identifiable {

    case onboarding
    case enterPhone

    var id: Self { self }
    
    // swiftlint: disable force_cast
    func path<T: Equatable>() -> CasePath<ScreenProviderState, T> {
        switch self {
        case .onboarding:
            return /ScreenProviderState.onboarding as! CasePath<ScreenProviderState, T>
        case .enterPhone:
            return /ScreenProviderState.enterPhone as! CasePath<ScreenProviderState, T>
        }
    }
}

enum ScreenProviderState: Equatable, Identifiable {
    case onboarding(OnboardingState)
    case enterPhone(EnterPhoneState)

    var id: RoutePath.ID {
        switch self {
        case .enterPhone:
            return RoutePath.enterPhone
        case .onboarding:
            return RoutePath.onboarding
        }
    }
}

enum ScreenProviderAction: Equatable {
    case onboarding(OnboardingAction)
    case enterPhone(EnterPhoneAction)
}

let screenProviderReducer = Reducer<ScreenProviderState, ScreenProviderAction, LoginFlowEnvironment>.combine(
    onboardingReducer
        .pullback(
            state: /ScreenProviderState.onboarding,
            action: /ScreenProviderAction.onboarding,
            environment: { _ in OnboardingEnvironment() }
        ),
    enterPhoneReducer
        .pullback(
            state: /ScreenProviderState.enterPhone,
            action: /ScreenProviderAction.enterPhone,
            environment: { _ in EnterPhoneEnvironment() }
        )
)

struct LoginFlowView: View {

    let store: Store<LoginFlowState, LoginFlowAction>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /ScreenProviderState.onboarding,
                    action: ScreenProviderAction.onboarding,
                    then: OnboardingView.init
                )
                CaseLet(
                    state: /ScreenProviderState.enterPhone,
                    action: ScreenProviderAction.enterPhone,
                    then: EnterPhoneView.init
                )
            }
        }
    }
}

// MARK: - LoginFlow

struct LoginFlowState: Equatable, IdentifiedRouterState {

    var routes: IdentifiedArrayOf<Route<ScreenProviderState>>

    static let initialState = LoginFlowState(
        routes: [
            .root(.onboarding(OnboardingState()), embedInNavigationView: true)
        ]
    )

    func routeState<T: Equatable>(routePath: RoutePath) -> T? {
        if let screenProviderState = routes[id: routePath.id]?.screen {
            let casePath: CasePath<ScreenProviderState, T> = routePath.path()
            return casePath.extract(from: screenProviderState)
        } else {
            return nil
        }
    }
}

enum LoginFlowAction: Equatable, IdentifiedRouterAction {

    case verificationIDReceived(Result<String, NSError>)
    case authDataReceived(Result<AuthDataResult, NSError>)
    case loginSuccess

    case routeAction(ScreenProviderState.ID, action: ScreenProviderAction)
    case updateRoutes(IdentifiedArrayOf<Route<ScreenProviderState>>)
}

struct LoginFlowEnvironment { }

let loginFlowReducerCore = Reducer<LoginFlowState, LoginFlowAction, LoginFlowEnvironment> { state, action, environment in
    switch action {
    case .routeAction(_, action: .enterPhone(.binding(\.$phoneNumber))):
        guard let enterPhoneState: EnterPhoneState = state.routeState(routePath: .enterPhone) else {
            return .none
        }
        print("!!!!!!!!!! \(enterPhoneState.phoneNumber)")
        return .none

    case .routeAction(_, action: .onboarding(.startMessaging)):
        print("Start messanging")
        state.routes.push(.enterPhone(.init(phoneNumber: "+380")))
        return .none

    default:
        return .none
    }
}

let loginFlowReducer = Reducer<LoginFlowState, LoginFlowAction, LoginFlowEnvironment>.combine(
    screenProviderReducer
        .forEachIdentifiedRoute(environment: { _ in .init() })
        .withRouteReducer(
            loginFlowReducerCore
        )
)
