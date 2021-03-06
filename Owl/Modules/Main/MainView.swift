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
                CaseLet(
                    state: /Main.ScreenProvider.State.newPrivateChat,
                    action: Main.ScreenProvider.Action.newPrivateChat,
                    then: { NewPrivateChatView(store: $0) }
                )
                CaseLet(
                    state: /Main.ScreenProvider.State.profile,
                    action: Main.ScreenProvider.Action.profile,
                    then: { ProfileView(store: $0) }
                )
                CaseLet(
                    state: /Main.ScreenProvider.State.editProfile,
                    action: Main.ScreenProvider.Action.editProfile,
                    then: { EditProfileView(store: $0) }
                )
            }
        }
    }
}
