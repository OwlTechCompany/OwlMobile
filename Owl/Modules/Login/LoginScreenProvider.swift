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

extension Login.ScreenProvider: ReducerProtocol {

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
        static var statePath = /State.enterUserData
    }

    struct SetupPermissionsRoute: Routable {
        static var statePath = /State.setupPermissions
    }

    // MARK: - State handling

    enum State: Equatable, Identifiable {
        case onboarding(Onboarding.State)
        case enterPhone(EnterPhone.State)
        case enterCode(EnterCode.State)
        case enterUserData(EnterUserData.State)
        case setupPermissions(SetupPermissions.State)

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
            case .setupPermissions:
                return SetupPermissionsRoute.id
            }
        }
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case onboarding(Onboarding.Action)
        case enterPhone(EnterPhone.Action)
        case enterCode(EnterCode.Action)
        case enterUserData(EnterUserData.Action)
        case setupPermissions(SetupPermissions.Action)
    }

    // MARK: - Reducer handling

    var body: some ReducerProtocol<State, Action> {
        Scope(
            state: /State.onboarding,
            action: /Action.onboarding
        ) {
            Onboarding()
        }

        Scope(
            state: /State.enterPhone,
            action: /Action.enterPhone
        ) {
            EnterPhone()
        }

        Scope(
            state: /State.enterCode,
            action: /Action.enterCode
        ) {
            EnterCode()
        }

        Scope(
            state: /State.enterUserData,
            action: /Action.enterUserData
        ) {
            EnterUserData()
        }

        Scope(
            state: /State.setupPermissions,
            action: /Action.setupPermissions
        ) {
            SetupPermissions()
        }
    }

}
