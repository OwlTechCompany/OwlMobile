//
//  MainView.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct MainView: View {

    var store: Store<Main.State, Main.Action>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /Main.ScreenProvider.State.chatList,
                    action: Main.ScreenProvider.Action.chatList,
                    then: ChatListView.init
                )
                CaseLet(
                    state: /Main.ScreenProvider.State.chat,
                    action: Main.ScreenProvider.Action.chat,
                    then: ChatView.init
                )
            }
        }
    }
}
