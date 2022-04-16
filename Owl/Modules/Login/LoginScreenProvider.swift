//
//  LoginScreenProvider.swift
//  Owl
//
//  Created by Denys Danyliuk on 12.04.2022.
//

import ComposableArchitecture
import TCACoordinators

extension Login {

    struct ScreenProvider {}
}

extension Login.ScreenProvider {

    // MARK: - Routes

    struct OnboardingRoute: Routable {
        static var statePath = /State.onboarding
    }

    struct EnterPhoneRoute: Routable {
        static var statePath = /State.enterPhone
    }

    struct EnterCodeRoute: Routable {
        static var statePath = /State.enterCode
    }

    struct EnterUserDataRoute: Routable {
        static var statePath = /State.enterCode
    }

    // MARK: - State handling

    enum State: Equatable, Identifiable {
        case onboarding(Onboarding.State)
        case enterPhone(EnterPhone.State)
        case enterCode(EnterCode.State)
        case enterUserData(EnterUserData.State)

        var id: String {
            switch self {
            case .onboarding:
                return OnboardingRoute.id
            case .enterPhone:
                return EnterPhoneRoute.id
            case .enterCode:
                return EnterCodeRoute.id
            case .enterUserData:
                return EnterUserDataRoute.id
            }
        }
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case onboarding(Onboarding.Action)
        case enterPhone(EnterPhone.Action)
        case enterCode(EnterCode.Action)
        case enterUserData(EnterUserData.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Login.Environment>.combine(
        Onboarding.reducer
            .pullback(
                state: /State.onboarding,
                action: /Action.onboarding,
                environment: { _ in Onboarding.Environment() }
            ),
        EnterPhone.reducer
            .pullback(
                state: /State.enterPhone,
                action: /Action.enterPhone,
                environment: {
                    EnterPhone.Environment(
                        authClient: $0.authClient,
                        userDefaultsClient: $0.userDefaultsClient,
                        phoneValidation: $0.validationClient.phoneValidation
                    )
                }
            ),
        EnterCode.reducer
            .pullback(
                state: /State.enterCode,
                action: /Action.enterCode,
                environment: {
                    EnterCode.Environment(
                        authClient: $0.authClient,
                        userDefaultsClient: $0.userDefaultsClient,
                        firestoreUsersClient: $0.firestoreUsersClient
                    )
                }
            ),
        EnterUserData.reducer
            .pullback(
                state: /State.enterUserData,
                action: /Action.enterUserData,
                environment: { _ in EnterUserData.Environment() }
            )
    )

}
