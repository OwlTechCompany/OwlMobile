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

    enum State: Equatable, Hashable {
        case onboarding(Onboarding.State)
        case enterPhone(EnterPhone.State)
        case enterCode(EnterCode.State)
        case enterUserData(EnterUserData.State)
        case setupPermissions(SetupPermissions.State)
    }

    enum Action: Equatable {
        case onboarding(Onboarding.Action)
        case enterPhone(EnterPhone.Action)
        case enterCode(EnterCode.Action)
        case enterUserData(EnterUserData.Action)
        case setupPermissions(SetupPermissions.Action)
    }

    // MARK: - Reducer handling

    var body: some ReducerProtocolOf<Self> {
        ScopeCase(
            state: /State.onboarding,
            action: /Action.onboarding
        ) {
            Onboarding()
        }

        ScopeCase(
            state: /State.enterPhone,
            action: /Action.enterPhone
        ) {
            EnterPhone()
        }

        ScopeCase(
            state: /State.enterCode,
            action: /Action.enterCode
        ) {
            EnterCode()
        }

        ScopeCase(
            state: /State.enterUserData,
            action: /Action.enterUserData
        ) {
            EnterUserData()
        }

        ScopeCase(
            state: /State.setupPermissions,
            action: /Action.setupPermissions
        ) {
            SetupPermissions()
        }
    }

}
