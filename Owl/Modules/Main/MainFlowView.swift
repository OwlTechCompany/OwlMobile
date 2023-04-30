//
//  MainFlowView.swift
//  Owl
//
//  Created by Denys Danyliuk on 07.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct MainFlowView: View {
    let store: StoreOf<MainFlowCoordinator>
    
    var body: some View {
        EmptyView()
        NavigationStackStore(
            store.scope(state: \.path, action: MainFlowCoordinator.Action.path),
            root: {
                ChatListView(store: store.scope(state: \.chatList, action: MainFlowCoordinator.Action.chatList))
            },
            destination: { path in
                switch path {
                case .chat:
                    CaseLet(
                        state: /MainFlowCoordinator.Path.State.chat,
                        action: MainFlowCoordinator.Path.Action.chat,
                        then: ChatView.init
                    )
                case .profile:
                    CaseLet(
                        state: /MainFlowCoordinator.Path.State.profile,
                        action: MainFlowCoordinator.Path.Action.profile,
                        then: ProfileView.init
                    )
                case .editProfile:
                    CaseLet(
                        state: /MainFlowCoordinator.Path.State.editProfile,
                        action: MainFlowCoordinator.Path.Action.editProfile,
                        then: EditProfileView.init
                    )
                    
                case .newPrivateChat:
                    CaseLet(
                        state: /MainFlowCoordinator.Path.State.newPrivateChat,
                        action: MainFlowCoordinator.Path.Action.newPrivateChat,
                        then: NewPrivateChatView.init
                    )
                }
            }
        )
    }
}
