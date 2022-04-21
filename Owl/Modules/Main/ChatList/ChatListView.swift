//
//  ChatListView.swift
//  Owl
//
//  Created by Anastasia Holovash on 15.04.2022.
//

import SwiftUI
import ComposableArchitecture

struct ChatListView: View {

    var store: Store<ChatList.State, ChatList.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                List {
                    ForEachStore(
                        self.store.scope(
                            state: \.chats,
                            action: ChatList.Action.chats(id:action:)
                        ),
                        content: { ChatListCellView(store: $0) }
                    )
                }
                .listStyle(.plain)
            }
            .navigationTitle("Owl")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                HStack {
                    Spacer()

                    Button(
                        action: { viewStore.send(.logout) },
                        label: { Text("Logout") }
                    )
                    .padding()
                }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

// MARK: - Preview

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(store: Store(
            initialState: ChatList.State(
                chats: .init(
                    arrayLiteral:
                        ChatListCell.State(model: MockedDataClient.chatsListPrivateItem)
                ),
                chatsData: []
            ),
            reducer: ChatList.reducer,
            environment: ChatList.Environment(
                authClient: .live,
                chatsClient: .live
            )
        ))
    }
}
