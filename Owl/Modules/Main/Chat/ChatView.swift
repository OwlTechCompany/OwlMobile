//
//  ChatView.swift
//  Owl
//
//  Created by Anastasia Holovash on 16.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatView: View {
    let store: Store<Chat.State, Chat.Action>

    var body: some View {

        WithViewStore(self.store) { viewStore in
            VStack {
                Text("Hello, World!")

            }
            .toolbar {
                ChatNavigationView(
                    store: store.scope(
                        state: \.navigation,
                        action: Chat.Action.navigation
                    )
                )
            }
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(store: Store(
            initialState: .init(
                navigation: MockedDataClient.chatNavigationState
            ),
            reducer: Chat.reducer,
            environment: Chat.Environment()
        ))
    }
}
