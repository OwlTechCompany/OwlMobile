//
//  LoginScreenProvider.swift
//  Owl
//
//  Created by Denys Danyliuk on 12.04.2022.
//

import ComposableArchitecture
import TCACoordinators

// MARK: - Routes

struct OnboardingRoute: Routable {
    static var statePath = /LoginScreenProviderState.onboarding
}

struct EnterPhoneRoute: Routable {
    static var statePath = /LoginScreenProviderState.enterPhone
}

struct EnterCodeRoute: Routable {
    static var statePath = /LoginScreenProviderState.enterCode
}

// MARK: - State handling

enum LoginScreenProviderState: Equatable, Identifiable {
    case onboarding(OnboardingState)
    case enterPhone(EnterPhoneState)
    case enterCode(EnterCodeState)

    var id: String {
        switch self {
        case .onboarding:
            return OnboardingRoute.id
        case .enterPhone:
            return EnterPhoneRoute.id
        case .enterCode:
            return EnterCodeRoute.id
        }
    }
}

// MARK: - Action handling

enum LoginScreenProviderAction: Equatable {
    case onboarding(OnboardingAction)
    case enterPhone(EnterPhoneAction)
    case enterCode(EnterCodeAction)
}

// MARK: - Reducer handling

typealias LoginScreenProviderReducer = Reducer<
    LoginScreenProviderState,
    LoginScreenProviderAction,
    LoginFlowEnvironment
>

let loginScreenProviderReducer = LoginScreenProviderReducer.combine(
    onboardingReducer
        .pullback(
            state: /LoginScreenProviderState.onboarding,
            action: /LoginScreenProviderAction.onboarding,
            environment: { _ in OnboardingEnvironment() }
        ),
    enterPhoneReducer
        .pullback(
            state: /LoginScreenProviderState.enterPhone,
            action: /LoginScreenProviderAction.enterPhone,
            environment: { _ in EnterPhoneEnvironment() }
        ),
    enterCodeReducer
        .pullback(
            state: /LoginScreenProviderState.enterCode,
            action: /LoginScreenProviderAction.enterCode,
            environment: { _ in EnterCodeEnvironment() }
        )
)
