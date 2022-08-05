//
//  LoginView.swift
//  Owl
//
//  Created by Denys Danyliuk on 13.04.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct LoginView: View {

    let store: StoreOf<Login>

    var body: some View {
        NavigationStackStore(self.store.scope(state: \.$path, action: Login.Action.path)) {
            // TODO: Make OnboardingView root view
            Rectangle()
                .fill(Color.clear)
                .navigationDestination(
                    store: self.store.scope(state: \.$path, action: Login.Action.path)
                ) { store in
                    SwitchStore(store) {
                        CaseLet(
                            state: /Login.ScreenProvider.State.onboarding,
                            action: Login.ScreenProvider.Action.onboarding,
                            then: OnboardingView.init
                        )
                        CaseLet(
                            state: /Login.ScreenProvider.State.enterPhone,
                            action: Login.ScreenProvider.Action.enterPhone,
                            then: EnterPhoneView.init
                        )
                        CaseLet(
                            state: /Login.ScreenProvider.State.enterCode,
                            action: Login.ScreenProvider.Action.enterCode,
                            then: EnterCodeView.init
                        )
                        CaseLet(
                            state: /Login.ScreenProvider.State.setupPermissions,
                            action: Login.ScreenProvider.Action.setupPermissions,
                            then: SetupPermissionsView.init
                        )
                        CaseLet(
                            state: /Login.ScreenProvider.State.enterUserData,
                            action: Login.ScreenProvider.Action.enterUserData,
                            then: EnterUserDataView.init
                        )
                    }
                }
        }
    }

}
