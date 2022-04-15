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
                HStack {
                    Spacer()

                    Button(
                        action: { viewStore.send(.logout) },
                        label: {
                            Text("Logout")
                        }
                    )
                    .padding()
                }

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
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Preview

struct ChatListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatListView(store: Store(
            initialState: ChatList.State(
                chats: .init(arrayLiteral:
                    ChatListCell.State(
                        documentID: "123",
                        chatImage: Asset.Images.owlBlack.image,
                        chatName: "Test chat",
                        lastMessage: "Hello world",
                        lastMessageSendTime: Date()
                    )
                )
            ),
            reducer: ChatList.reducer,
            environment: ChatList.Environment()
        ))
    }
}
