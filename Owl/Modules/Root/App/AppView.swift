//
//  AppView.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {

    let store: Store<App.State, App.Action>

    var body: some View {
        Group {
            IfLetStore(
                store.scope(state: \App.State.login, action: App.Action.login),
                then: LoginFlowView.init
            )
            IfLetStore(
                store.scope(state: \App.State.main, action: App.Action.main),
                then: MainView.init
            )
        }
    }

}
