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
                List {
                    ForEachStore(
                        self.store.scope(
                            state: \.messages,
                            action: Chat.Action.messages(id:action:)
                        ),
                        content: { ChatMessageView(store: $0) }
                    )
                }
                .listStyle(.plain)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ChatNavigationView(
                        store: store.scope(
                            state: \.navigation,
                            action: Chat.Action.navigation
                        )
                    )
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(store: Store(
                initialState: .init(
                    navigation: .init(model: MockedDataClient.chatsListPrivateItem),
                    messages: .init(
                        uniqueElements: MockedDataClient.chatMessages.map {
                            ChatMessage.State(
                                message: $0,
                                companion: MockedDataClient.chatsListPrivateItem.companion
                            )
                        }
                    )
                ),
                reducer: Chat.reducer,
                environment: Chat.Environment()
            ))
        }
    }
}
