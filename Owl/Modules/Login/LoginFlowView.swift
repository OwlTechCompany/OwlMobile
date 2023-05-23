//
//  LoginFlowView.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct LoginFlowView: View {
    let store: StoreOf<LoginFlowCoordinator>

    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: LoginFlowCoordinator.Action.path),
            root: {
                OnboardingView(store: store.scope(state: \.onboarding, action: LoginFlowCoordinator.Action.onboarding))
            },
            destination: { path in
                switch path {
                case .enterPhone:
                    CaseLet(
                        state: /LoginFlowCoordinator.Path.State.enterPhone,
                        action: LoginFlowCoordinator.Path.Action.enterPhone,
                        then: EnterPhoneView.init
                    )
                case .enterCode:
                    CaseLet(
                        state: /LoginFlowCoordinator.Path.State.enterCode,
                        action: LoginFlowCoordinator.Path.Action.enterCode,
                        then: EnterCodeView.init
                    )
                case .setupPermissions:
                    CaseLet(
                        state: /LoginFlowCoordinator.Path.State.setupPermissions,
                        action: LoginFlowCoordinator.Path.Action.setupPermissions,
                        then: SetupPermissionsView.init
                    )
                case .enterUserData:
                    CaseLet(
                        state: /LoginFlowCoordinator.Path.State.enterUserData,
                        action: LoginFlowCoordinator.Path.Action.enterUserData,
                        then: EnterUserDataView.init
                    )
                }
            }
        )
    }
}
