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
                ToolbarItem(placement: .navigationBarLeading) {
                    PhotoWebImage(user: viewStore.user, useResize: true)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .modifier(ShadowModifier())
                        .onTapGesture { viewStore.send(.openProfile) }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Private chat", action: { viewStore.send(.newPrivateChat) })
                        Button("Group", action: {})
                            .disabled(true)
                    } label: {
                        Label("", systemImage: "square.and.pencil")
                    }
                    .padding()
                }
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

// MARK: - Preview

struct ChatListView_Previews: PreviewProvider {

    static let userClient = UserClient.live(userDefaults: .live())

    static var previews: some View {
        ChatListView(store: Store(
            initialState: ChatList.State(
                user: User(
                    uid: "",
                    phoneNumber: "",
                    firstName: "",
                    lastName: "",
                    photo: .placeholder
                ),
                chats: .init(
                    arrayLiteral:
                        ChatListCell.State(
                            id: "123",
                            photo: .placeholder,
                            chatName: "Test chat",
                            lastMessage: "Hello world",
                            lastMessageSendTime: Date(),
                            unreadMessagesNumber: 4
                        )
                )
            ),
            reducer: ChatList.reducer,
            environment: ChatList.Environment(
                authClient: .live,
                chatsClient: .live(userClient: userClient),
                userClient: userClient
            )
        ))
    }
}
